package kube

deployment: cortex: spec: template: spec: {
	containers: [{
		image: "cortexproject/cortex:v1.15.2"
		args: [
			"-config.file=/tmp/config.yaml",
		]
		env: [{
			name: "TMPDIR"
			value: "/data/"
		}]
		ports: [{
			containerPort: 9009
		}]
		volumeMounts: [{
			name:      "config"
			mountPath: "/tmp/"
		}]
	}]
	volumes: [{
		name: "config"
		configMap: name: "cortex"
	}]
}
