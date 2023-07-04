package kube

deployment: minio: spec: template: spec: {
	containers: [{
		image: "quay.io/minio/minio:RELEASE.2023-05-27T05-56-19Z"
		args: [
			"server",
			"/data",
			"--console-address",
			":9090",
		]
		ports: [{
			containerPort: 9000
		}, {
			containerPort: 9090
		}]
		volumeMounts: [{
			name:      "localvolume"
			mountPath: "/data/"
		}]
	}]
	volumes: [{
		name: "localvolume"
		emptyDir: sizeLimit: "5Mi"
	}]
}
