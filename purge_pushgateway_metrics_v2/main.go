package main

import (
	"bufio"
	"flag"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

var (
	urlMetricsPushGateWay     string
	timeoutMetricsPushGateWay int
	timeIntervalCheck         time.Duration
	timeSecondClearMetrics    int
	showHelp                  bool
)

func init() {
	flag.StringVar(&urlMetricsPushGateWay, "urlMetricsPushGateWay", "http://17.0.0.1:9091", "URL of the PushGateWay service")
	flag.IntVar(&timeoutMetricsPushGateWay, "timeoutMetricsPushGateWay", 30, "Timeout seconds connect from client to PushGateWay")
	flag.DurationVar(&timeIntervalCheck, "timeIntervalCheck", 29*time.Second, "Time interval for checking metrics")
	flag.IntVar(&timeSecondClearMetrics, "timeSecondClearMetrics", 60, "Time seconds to clear metrics")
	flag.BoolVar(&showHelp, "help", false, "Show help message")

	flag.Parse()

	if showHelp {
		flag.Usage()
		os.Exit(0)
	}
}

func getMetrics() (string, error) {
	resp, err := http.Get(urlMetricsPushGateWay + "/metrics")
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("failed to fetch metrics with status code: %d", resp.StatusCode)
	}

	scanner := bufio.NewScanner(resp.Body)
	var metricsText strings.Builder
	for scanner.Scan() {
		metricsText.WriteString(scanner.Text() + "\n")
	}

	return metricsText.String(), scanner.Err()
}

func parseAndDeleteMetrics(metricsText string) {
	lines := strings.Split(metricsText, "\n")
	stdUnixTimeNow := time.Now().Unix()

	for _, line := range lines {
		if strings.HasPrefix(line, "push_time_seconds") {
			// Lấy phần labels bên trong dấu ngoặc nhọn {}
			start := strings.Index(line, "{")
			end := strings.Index(line, "}")
			labelsPart := line[start+1 : end]
			labels := strings.Split(labelsPart, ",")

			// Tạo một map từ labels
			labelDict := make(map[string]string)
			for _, label := range labels {
				parts := strings.Split(label, "=")
				key := strings.TrimSpace(parts[0])
				value := strings.Trim(parts[1], "\"")
				labelDict[key] = value
			}

			// Lấy giá trị của push_time_seconds
			parts := strings.Fields(line)
			if len(parts) < 2 {
				continue
			}
			lastPushed, err := strconv.ParseFloat(parts[1], 64)
			if err != nil {
				fmt.Printf("Error parsing push_time_seconds: %v\n", err)
				continue
			}

			// So sánh thời gian tồn tại
			intervalSeconds := stdUnixTimeNow - int64(lastPushed)
			if intervalSeconds > int64(timeSecondClearMetrics) {
				// Tạo URL DELETE
				deleteURL := fmt.Sprintf("%s/metrics/job/%s", urlMetricsPushGateWay, labelDict["job"])
				for key, value := range labelDict {
					if key != "job" { // Giữ lại các labels khác job
						deleteURL += fmt.Sprintf("/%s/%s", key, value)
					}
				}

				fmt.Printf("Deleting metrics for: %v\n", labelDict)
				req, err := http.NewRequest(http.MethodDelete, deleteURL, nil)
				if err != nil {
					fmt.Printf("Error creating DELETE request: %v\n", err)
					continue
				}

				resp, err := http.DefaultClient.Do(req)
				if err != nil {
					fmt.Printf("Error deleting metrics: %v\n", err)
					continue
				}
				defer resp.Body.Close()

				if resp.StatusCode == http.StatusAccepted {
					fmt.Printf("Successfully deleted metrics for: %v\n", labelDict)
				} else {
					fmt.Printf("Failed to delete metrics with status code: %d\n", resp.StatusCode)
				}
			} else {
				fmt.Printf("Purge action skipped for %v. Interval not satisfied: %d seconds\n", labelDict, intervalSeconds)
			}
		}
	}
}

func main() {
	for {
		metricsText, err := getMetrics()
		if err != nil {
			fmt.Printf("Error getting metrics: %v\n", err)
			return
		}

		parseAndDeleteMetrics(metricsText)

		// Wait for the specified interval before the next check
		time.Sleep(timeIntervalCheck)
	}
}
