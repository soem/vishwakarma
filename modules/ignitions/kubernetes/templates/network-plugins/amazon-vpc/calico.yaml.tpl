# Vendored from https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.6/calico.yaml
kind: DaemonSet
apiVersion: apps/v1
metadata:
  name: calico-node
  namespace: kube-system
  labels:
    k8s-app: calico-node
spec:
  selector:
    matchLabels:
      k8s-app: calico-node
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        k8s-app: calico-node
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      nodeSelector:
        beta.kubernetes.io/os: linux
      hostNetwork: true
      serviceAccountName: calico-node
      terminationGracePeriodSeconds: 0
      containers:
        - name: calico-node
          image: ${node_image}
          env:
            # Use Kubernetes API as the backing datastore.
            - name: DATASTORE_TYPE
              value: "kubernetes"
            # Use eni not cali for interface prefix
            - name: FELIX_INTERFACEPREFIX
              value: "eni"
            # Enable felix info logging.
            - name: FELIX_LOGSEVERITYSCREEN
              value: "info"
            # Don't enable BGP.
            - name: CALICO_NETWORKING_BACKEND
              value: "none"
            # Cluster type to identify the deployment type
            - name: CLUSTER_TYPE
              value: "k8s,ecs"
            # Disable file logging so `kubectl logs` works.
            - name: CALICO_DISABLE_FILE_LOGGING
              value: "true"
            - name: FELIX_TYPHAK8SSERVICENAME
              value: "calico-typha"
            # Set Felix endpoint to host default action to ACCEPT.
            - name: FELIX_DEFAULTENDPOINTTOHOSTACTION
              value: "ACCEPT"
            # This will make Felix honor AWS VPC CNI's mangle table
            # rules.
            - name: FELIX_IPTABLESMANGLEALLOWACTION
              value: Return
            # Disable IPV6 on Kubernetes.
            - name: FELIX_IPV6SUPPORT
              value: "false"
            # Wait for the datastore.
            - name: WAIT_FOR_DATASTORE
              value: "true"
            - name: FELIX_LOGSEVERITYSYS
              value: "none"
            - name: FELIX_PROMETHEUSMETRICSENABLED
              value: "true"
            - name: NO_DEFAULT_POOLS
              value: "true"
            # Set based on the k8s node name.
            - name: NODENAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
            # No IP address needed.
            - name: IP
              value: ""
            - name: FELIX_HEALTHENABLED
              value: "true"
          securityContext:
            privileged: true
          livenessProbe:
            httpGet:
              path: /liveness
              port: 9099
              host: localhost
            periodSeconds: 10
            initialDelaySeconds: 10
            failureThreshold: 6
          readinessProbe:
            exec:
              command:
                - /bin/calico-node
                - -felix-ready
            periodSeconds: 10
          volumeMounts:
            - mountPath: /lib/modules
              name: lib-modules
              readOnly: true
            - mountPath: /run/xtables.lock
              name: xtables-lock
              readOnly: false
            - mountPath: /var/run/calico
              name: var-run-calico
              readOnly: false
            - mountPath: /var/lib/calico
              name: var-lib-calico
              readOnly: false
      volumes:
        # Used to ensure proper kmods are installed.
        - name: lib-modules
          hostPath:
            path: /lib/modules
        - name: var-run-calico
          hostPath:
            path: /var/run/calico
        - name: var-lib-calico
          hostPath:
            path: /var/lib/calico
        - name: xtables-lock
          hostPath:
            path: /run/xtables.lock
            type: FileOrCreate
      tolerations:
        # Make sure calico/node gets scheduled on all nodes.
        - effect: NoSchedule
          operator: Exists
        # Mark the pod as a critical add-on for rescheduling.
        - key: CriticalAddonsOnly
          operator: Exists
        - effect: NoExecute
          operator: Exists
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: felixconfigurations.crd.projectcalico.org
spec:
  scope: Cluster
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: FelixConfiguration
    plural: felixconfigurations
    singular: felixconfiguration
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: ipamblocks.crd.projectcalico.org
spec:
  scope: Cluster
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: IPAMBlock
    plural: ipamblocks
    singular: ipamblock
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: blockaffinities.crd.projectcalico.org
spec:
  scope: Cluster
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: BlockAffinity
    plural: blockaffinities
    singular: blockaffinity
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: bgpconfigurations.crd.projectcalico.org
spec:
  scope: Cluster
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: BGPConfiguration
    plural: bgpconfigurations
    singular: bgpconfiguration
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: bgppeers.crd.projectcalico.org
spec:
  scope: Cluster
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: BGPPeer
    plural: bgppeers
    singular: bgppeer
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: ippools.crd.projectcalico.org
spec:
  scope: Cluster
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: IPPool
    plural: ippools
    singular: ippool
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: hostendpoints.crd.projectcalico.org
spec:
  scope: Cluster
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: HostEndpoint
    plural: hostendpoints
    singular: hostendpoint
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: clusterinformations.crd.projectcalico.org
spec:
  scope: Cluster
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: ClusterInformation
    plural: clusterinformations
    singular: clusterinformation
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: globalnetworkpolicies.crd.projectcalico.org
spec:
  scope: Cluster
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: GlobalNetworkPolicy
    plural: globalnetworkpolicies
    singular: globalnetworkpolicy
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: globalnetworksets.crd.projectcalico.org
spec:
  scope: Cluster
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: GlobalNetworkSet
    plural: globalnetworksets
    singular: globalnetworkset
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: networkpolicies.crd.projectcalico.org
spec:
  scope: Namespaced
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: NetworkPolicy
    plural: networkpolicies
    singular: networkpolicy
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: networksets.crd.projectcalico.org
spec:
  scope: Namespaced
  group: crd.projectcalico.org
  versions:
    - name: v1
      served: true
      storage: true
  names:
    kind: NetworkSet
    plural: networksets
    singular: networkset
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: calico-node
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: calico-node
rules:
  - apiGroups: [""]
    resources:
      - namespaces
      - serviceaccounts
    verbs:
      - get
      - list
      - watch
  - apiGroups: [""]
    resources:
      - pods/status
    verbs:
      - patch
  - apiGroups: [""]
    resources:
      - nodes/status
    verbs:
      - patch
      - update
  - apiGroups: [""]
    resources:
      - pods
    verbs:
      - get
      - list
      - watch
  - apiGroups: [""]
    resources:
      - services
    verbs:
      - get
  - apiGroups: [""]
    resources:
      - endpoints
    verbs:
      - get
  - apiGroups: [""]
    resources:
      - nodes
    verbs:
      - get
      - list
      - update
      - watch
  - apiGroups: ["extensions"]
    resources:
      - networkpolicies
    verbs:
      - get
      - list
      - watch
  - apiGroups: ["networking.k8s.io"]
    resources:
      - networkpolicies
    verbs:
      - watch
      - list
  - apiGroups: ["crd.projectcalico.org"]
    resources:
      - globalfelixconfigs
      - felixconfigurations
      - bgppeers
      - globalbgpconfigs
      - bgpconfigurations
      - ippools
      - ipamblocks
      - globalnetworkpolicies
      - globalnetworksets
      - networkpolicies
      - networksets
      - clusterinformations
      - hostendpoints
    verbs:
      - create
      - get
      - list
      - update
      - watch
  - apiGroups: ["crd.projectcalico.org"]
    resources:
      - blockaffinities
      - ipamblocks
      - ipamhandles
    verbs:
      - get
      - list
      - create
      - update
      - delete
  - apiGroups: ["crd.projectcalico.org"]
    resources:
      - blockaffinities
    verbs:
      - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: calico-node
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: calico-node
subjects:
  - kind: ServiceAccount
    name: calico-node
    namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: calico-typha
  namespace: kube-system
  labels:
    k8s-app: calico-typha
spec:
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      k8s-app: calico-typha
  template:
    metadata:
      labels:
        k8s-app: calico-typha
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
        cluster-autoscaler.kubernetes.io/safe-to-evict: 'true'
    spec:
      nodeSelector:
        beta.kubernetes.io/os: linux
      tolerations:
        # Mark the pod as a critical add-on for rescheduling.
        - key: CriticalAddonsOnly
          operator: Exists
      hostNetwork: true
      serviceAccountName: calico-node
      containers:
        - image: ${typha_image}
          name: calico-typha
          ports:
            - containerPort: 5473
              name: calico-typha
              protocol: TCP
          env:
            - name: FELIX_INTERFACEPREFIX
              value: "eni"
            - name: TYPHA_LOGFILEPATH
              value: "none"
            - name: TYPHA_LOGSEVERITYSYS
              value: "none"
            - name: TYPHA_LOGSEVERITYSCREEN
              value: "info"
            - name: TYPHA_PROMETHEUSMETRICSENABLED
              value: "true"
            - name: TYPHA_CONNECTIONREBALANCINGMODE
              value: "kubernetes"
            - name: TYPHA_PROMETHEUSMETRICSPORT
              value: "9093"
            - name: TYPHA_DATASTORETYPE
              value: "kubernetes"
            - name: TYPHA_MAXCONNECTIONSLOWERLIMIT
              value: "1"
            - name: TYPHA_HEALTHENABLED
              value: "true"
            - name: FELIX_IPTABLESMANGLEALLOWACTION
              value: Return
          livenessProbe:
            httpGet:
              path: /liveness
              port: 9098
              host: localhost
            periodSeconds: 30
            initialDelaySeconds: 30
          readinessProbe:
            httpGet:
              path: /readiness
              port: 9098
              host: localhost
            periodSeconds: 10
---
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: calico-typha
  namespace: kube-system
  labels:
    k8s-app: calico-typha
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      k8s-app: calico-typha
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: typha-cpha
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: typha-cpha
subjects:
  - kind: ServiceAccount
    name: typha-cpha
    namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: typha-cpha
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["list"]
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: calico-typha-horizontal-autoscaler
  namespace: kube-system
data:
  ladder: |-
    {
      "coresToReplicas": [],
      "nodesToReplicas":
      [
        [1, 1],
        [10, 2],
        [100, 3],
        [250, 4],
        [500, 5],
        [1000, 6],
        [1500, 7],
        [2000, 8]
      ]
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: calico-typha-horizontal-autoscaler
  namespace: kube-system
  labels:
    k8s-app: calico-typha-autoscaler
spec:
  selector:
    matchLabels:
      k8s-app: calico-typha-autoscaler
  replicas: 1
  template:
    metadata:
      labels:
        k8s-app: calico-typha-autoscaler
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      nodeSelector:
        beta.kubernetes.io/os: linux
      containers:
        - image: ${autoscaler_image}
          name: autoscaler
          command:
            - /cluster-proportional-autoscaler
            - --namespace=kube-system
            - --configmap=calico-typha-horizontal-autoscaler
            - --target=deployment/calico-typha
            - --logtostderr=true
            - --v=2
          resources:
            requests:
              cpu: 10m
            limits:
              cpu: 10m
      serviceAccountName: typha-cpha
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: typha-cpha
  namespace: kube-system
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get"]
  - apiGroups: ["extensions"]
    resources: ["deployments/scale"]
    verbs: ["get", "update"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: typha-cpha
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: typha-cpha
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: typha-cpha
subjects:
  - kind: ServiceAccount
    name: typha-cpha
    namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  name: calico-typha
  namespace: kube-system
  labels:
    k8s-app: calico-typha
spec:
  ports:
    - port: 5473
      protocol: TCP
      targetPort: calico-typha
      name: calico-typha
  selector:
    k8s-app: calico-typha
