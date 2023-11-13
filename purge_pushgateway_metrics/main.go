package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
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
	flag.StringVar(&urlMetricsPushGateWay, "urlMetricsPushGateWay", "http://127.0.0.1:9091/metrics", "URL of the PushGateWay service")
	flag.IntVar(&timeoutMetricsPushGateWay, "timeoutMetricsPushGateWay", 10, "Timeout seconds connect from client to PushGateWay")
	flag.DurationVar(&timeIntervalCheck, "timeIntervalCheck", 29*time.Second, "Time interval for checking metrics")
	flag.IntVar(&timeSecondClearMetrics, "timeSecondClearMetrics", 60, "Time second clear metrics")
	flag.BoolVar(&showHelp, "help", false, "Show help message")

	flag.Parse()

	if showHelp {
		flag.Usage()
		os.Exit(0)
	}
}

func main() {
	// var (
	// 	app                 = kingpin.New(filepath.Base(os.Args[0]), "The Pushgateway")
	// 	webConfig           = webflag.AddFlags(app, ":9091")
	// 	metricsPath         = app.Flag("web.telemetry-path", "Path under which to expose metrics.").Default("/metrics").String()
	// 	externalURL         = app.Flag("web.external-url", "The URL under which the Pushgateway is externally reachable.").Default("").URL()
	// 	routePrefix         = app.Flag("web.route-prefix", "Prefix for the internal routes of web endpoints. Defaults to the path of --web.external-url.").Default("").String()
	// 	enableLifeCycle     = app.Flag("web.enable-lifecycle", "Enable shutdown via HTTP request.").Default("false").Bool()
	// 	enableAdminAPI      = app.Flag("web.enable-admin-api", "Enable API endpoints for admin control actions.").Default("false").Bool()
	// 	persistenceFile     = app.Flag("persistence.file", "File to persist metrics. If empty, metrics are only kept in memory.").Default("").String()
	// 	persistenceInterval = app.Flag("persistence.interval", "The minimum interval at which to write out the persistence file.").Default("5m").Duration()
	// 	pushUnchecked       = app.Flag("push.disable-consistency-check", "Do not check consistency of pushed metrics. DANGEROUS.").Default("false").Bool()
	// 	promlogConfig       = promlog.Config{}
	// )

	currentDir, err := getCurrentDir()
	if err != nil {
		panic(err)
	}
	// removeOldLogs(currentDir)
	// deleteMetricsPushgatewayOld()
	for {
		removeOldLogs(currentDir)
		deleteMetricsPushgateway()
		// time.Sleep(29 * time.Second)
		time.Sleep(timeIntervalCheck)
	}
}

func deleteMetricsPushgateway() {

	// Ensure CURRENT_DIR is initialized for logs
	// currentDir := "/apps/scripts-golang"
	currentDir, err := getCurrentDir()
	if err != nil {
		panic(err)
	}

	fmt.Printf("Create folder logs %s/logs\n", currentDir)
	os.MkdirAll(currentDir+"/logs", os.ModePerm)

	// URL of the PushGateWay service
	// metricsURL := "http://127.0.0.1:9091/metrics"
	metricsURL := urlMetricsPushGateWay

	// Fetch metrics
	// metrics, err := fetchMetrics(metricsURL)
	// if err != nil {
	// 	fmt.Printf("Error: Unable to fetch metrics. %v\n", err)
	// 	os.Exit(1)
	// }

	metrics, err := fetchMetricsWithRetry(metricsURL, 3) // Retry up to 3 times
	if err != nil {
		fmt.Printf("Error: Unable to fetch metrics. %v\n", err)
		os.Exit(1)
	}

	delReq := metricsURL + "/job/"

	lines := strings.Split(metrics, "\n")
	for _, line := range lines {
		if strings.Contains(line, "push_time_seconds") && !strings.HasPrefix(line, "#") {
			fmt.Println("================================================================================================")
			fmt.Printf("test %s\n", line)

			fields := strings.Fields(line)
			lastPushed, err := parseFloat(fields[1])
			if err != nil {
				fmt.Printf("Error parsing last pushed time: %v\n", err)
				continue
			}

			fmt.Printf("Time last pushed metrics: %.f\n", lastPushed)

			// get info all job
			jobName := extractValueJobName(line, "job")
			//jobName, err := extractValueJobName(line)
			fmt.Printf("Job name: %s\n", jobName)

			// get info all instance
			instanceName := extractValueInstanceName(line, "instance")
			//instanceName, err := extractValueInstanceName(line)
			fmt.Printf("Instance name: %s\n", instanceName)

			stdUnixTimeNow := time.Now().Unix()
			intervalSeconds := stdUnixTimeNow - int64(lastPushed)
			fmt.Printf("Interval: %d seconds\n", intervalSeconds)

			if intervalSeconds > int64(timeSecondClearMetrics) {
				deleteURL := fmt.Sprintf("%s%s/instance/%s", delReq, jobName, instanceName)
				fmt.Printf("Command deleting : %s\n", deleteURL)
				if err := deleteInstance(deleteURL); err == nil {
					fmt.Printf("%s, Deleted job group - %s/instance/%s\n", time.Now().Format(time.RFC3339), jobName, instanceName)
				} else {
					fmt.Printf("%s, Error deleting job group - %s/instance/%s: %v\n", time.Now().Format(time.RFC3339), jobName, instanceName, err)
				}
			} else {
				fmt.Printf("%s, Purge action skipped. Interval not satisfied\n", time.Now().Format(time.RFC3339))
			}
		}
	}
}

func getCurrentDir() (string, error) {
	exePath, err := os.Executable()
	if err != nil {
		return "", err
	}

	return filepath.Dir(exePath), nil
}

func removeOldLogs(currentDir string) {
	for i := 10; i <= 20; i++ {
		timeAgo := time.Now().AddDate(0, 0, -i)
		ymdAgo := timeAgo.Format("20060102")
		logPath := filepath.Join(currentDir, "logs", fmt.Sprintf("_%s", ymdAgo))
		os.RemoveAll(logPath)
	}
}

func fetchMetricsWithRetry(url string, maxRetries int) (string, error) {
	var err error
	var body string

	for attempt := 1; attempt <= maxRetries; attempt++ {
		body, err = fetchMetrics(url)
		if err == nil {
			return body, nil
		}

		fmt.Printf("Error fetching metrics (attempt %d): %v\n", attempt, err)
		time.Sleep(5 * time.Second) // Wait for 5 seconds before retrying
	}

	return "", fmt.Errorf("Failed to fetch metrics after %d attempts", maxRetries)
}

// func fetchMetrics(url string) (string, error) {
// 	resp, err := http.Get(url)
// 	if err != nil {
// 		return "", err
// 	}
// 	defer resp.Body.Close()

// 	body, err := ioutil.ReadAll(resp.Body)
// 	if err != nil {
// 		return "", err
// 	}

// 	return string(body), nil
// }

func fetchMetrics(url string) (string, error) {
	client := http.Client{
		Timeout: time.Duration(timeoutMetricsPushGateWay) * time.Second, // Set a timeout for the HTTP request
	}

	resp, err := client.Get(url)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return string(body), nil
}

func parseFloat(s string) (float64, error) {
	return strconv.ParseFloat(s, 64)
}

func extractValueInstanceName(line, key string) string {
	startIndex := strings.Index(line, key+"=") + len(key) + 2
	endIndex := strings.Index(line[startIndex:], "\",job=")
	return line[startIndex : startIndex+endIndex]
}

func extractValueJobName(line, key string) string {
	startIndex := strings.Index(line, key+"=") + len(key) + 2
	endIndex := strings.Index(line[startIndex:], "\"}")
	return line[startIndex : startIndex+endIndex]
}

// func extractValue(line, key string) (string, error) {
// 	startIndex := strings.Index(line, key+"=") + len(key) + 1
// 	endIndex := strings.Index(line[startIndex:], " ")
// 	if endIndex == -1 {
// 		// If the key is the last part of the line
// 		return line[startIndex:], nil
// 	}
// 	return line[startIndex : startIndex+endIndex], nil
// }

// func extractValueJobName(line string) (string, error) {
// 	return extractValue(line, "job")
// }

// func extractValueInstanceName(line string) (string, error) {
// 	return extractValue(line, "instance")
// }

// func extractValueJobName(line string) (string, error) {
// 	// Split the line at '}'
// 	parts := strings.Split(line, "}")

// 	// Find the substring containing 'job='
// 	jobSubstring := strings.Fields(parts[0])
// 	for _, field := range jobSubstring {
// 		if strings.HasPrefix(field, "job=") {
// 			// Extract the job_name from 'job=' substring
// 			jobName := strings.Split(field, "=")[1]
// 			// Remove double quotes if present
// 			jobName = strings.Trim(jobName, "\"")
// 			return jobName, nil
// 		}
// 	}

// 	return "", fmt.Errorf("Job name not found in line: %s", line)
// }

func deleteInstance(url string) error {
	req, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		return err
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("HTTP error: %s", resp.Status)
	}

	return nil
}
