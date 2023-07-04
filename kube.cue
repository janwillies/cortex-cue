package kube

bucketName: "cortex"
k8s: namespace: "default"

service: [ID=_]: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: name: ID
	metadata: namespace: k8s.namespace
	metadata: labels: app: ID
	spec: {
		// Any port has the following properties.
		ports: [...{
			port:     int
			protocol: *"TCP" | "UDP"
			name:     string
		}]
		selector: metadata.labels
	}
}

deployment: [ID=_]: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: name: ID
    metadata: namespace: k8s.namespace
	metadata: labels: app: ID
	spec: {
		replicas: 1
		selector: matchLabels: app: ID
		template: {
			metadata: labels: app: ID
			spec: containers: [{name: ID}]
		}
	}
}

configMap: [ID=_]: {
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: name: ID
    metadata: namespace: k8s.namespace
	metadata: labels: app: ID
}
