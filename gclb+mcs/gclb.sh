# Create a global IPv4 address
gcloud compute addresses create x-gclb-mcs-ipv4 \
    --ip-version=IPV4 \
    --network-tier=PREMIUM \
    --global

# Create a customized health check
gcloud compute health-checks create http hc-whereami-version --request-path="/version" --port=8080

# Create a backend service which will be default backend service
gcloud compute backend-services create whereami \
    --load-balancing-scheme=EXTERNAL \
    --global-health-checks \
    --protocol HTTP \
    --health-checks hc-whereami-version \
    --global \
    --timeout="3600s"

# Add backend
gcloud compute backend-services add-backend whereami \
    --network-endpoint-group=k8s1-1778c3dc-test2-whereami-8080-e24654f8 \
    --network-endpoint-group-zone=asia-northeast1-a \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000

gcloud compute backend-services add-backend whereami \
    --network-endpoint-group=k8s1-1778c3dc-test2-whereami-8080-e24654f8 \
    --network-endpoint-group-zone=asia-northeast1-b \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000

gcloud compute backend-services add-backend whereami \
    --network-endpoint-group=k8s1-1778c3dc-test2-whereami-8080-e24654f8 \
    --network-endpoint-group-zone=asia-northeast1-c \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000

gcloud compute backend-services add-backend whereami \
    --network-endpoint-group=k8s1-aa6cdfd4-test2-whereami-8080-284b5b43 \
    --network-endpoint-group-zone=asia-northeast1-a \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000
gcloud compute backend-services add-backend whereami \
    --network-endpoint-group=k8s1-aa6cdfd4-test2-whereami-8080-284b5b43 \
    --network-endpoint-group-zone=asia-northeast1-b \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000
gcloud compute backend-services add-backend whereami \
    --network-endpoint-group=k8s1-aa6cdfd4-test2-whereami-8080-284b5b43 \
    --network-endpoint-group-zone=asia-northeast1-c \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000

gcloud compute backend-services add-backend whereami \
    --network-endpoint-group=k8s1-c093cc3a-test2-whereami-8080-d5737a3c \
    --network-endpoint-group-zone=asia-northeast2-a \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000
gcloud compute backend-services add-backend whereami \
    --network-endpoint-group=k8s1-c093cc3a-test2-whereami-8080-d5737a3c \
    --network-endpoint-group-zone=asia-northeast2-b \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000
gcloud compute backend-services add-backend whereami \
    --network-endpoint-group=k8s1-c093cc3a-test2-whereami-8080-d5737a3c \
    --network-endpoint-group-zone=asia-northeast2-c \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000

# Create an another backend service for header based routing
gcloud compute backend-services create osa1-whereami \
    --load-balancing-scheme=EXTERNAL \
    --global-health-checks \
    --protocol HTTP \
    --health-checks hc-whereami-version \
    --global \
    --timeout="3600s"

# Add backend
gcloud compute backend-services add-backend osa1-whereami \
    --network-endpoint-group=k8s1-c093cc3a-test2-osa1-whereami-8080-f80a136f \
    --network-endpoint-group-zone=asia-northeast2-a \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000
gcloud compute backend-services add-backend osa1-whereami \
    --network-endpoint-group=k8s1-c093cc3a-test2-osa1-whereami-8080-f80a136f \
    --network-endpoint-group-zone=asia-northeast2-b \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000
gcloud compute backend-services add-backend osa1-whereami \
    --network-endpoint-group=k8s1-c093cc3a-test2-osa1-whereami-8080-f80a136f \
    --network-endpoint-group-zone=asia-northeast2-c \
    --global \
    --balancing-mode=RATE \
    --max-rate=100000000

# Validate a url-map
gcloud compute url-maps validate --source gclb-mcs-urlmap.yaml

# Create a url-map
gcloud compute url-maps import gclb-mcs-urlmap --source gclb-mcs-urlmap.yaml --global

# Create a target proxy
gcloud compute target-http-proxies create x-gclb-mcs-proxy \
--url-map gclb-mcs-urlmap

# Create a forwarding-rule
gcloud compute forwarding-rules create x-gclb-mcs-fwrule \
    --load-balancing-scheme=EXTERNAL \
    --network-tier=PREMIUM \
    --address=x-gclb-mcs-ipv4 \
    --global \
    --target-http-proxy=x-gclb-mcs-proxy \
    --ports=80
