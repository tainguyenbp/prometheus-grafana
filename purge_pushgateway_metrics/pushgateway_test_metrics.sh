echo 'tainguyenbp_devops_metric{instance="localhost"} 4.15' | curl --data-binary @- http://localhost:9091/metrics/job/devops/instance/localhost
echo 'tainguyenbp_sre_metric{instance="localhost"} 5.16' | curl --data-binary @- http://localhost:9091/metrics/job/sre/instance/localhost
echo 'tainguyenbp_infrastructure_metric{instance="localhost"} 6.14' | curl --data-binary @- http://localhost:9091/metrics/job/infrastructure/instance/localhost
