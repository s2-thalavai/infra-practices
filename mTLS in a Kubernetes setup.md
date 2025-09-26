# Mutual TLS (mTLS) in Kubernetes Microservices

## Architecture Overview

This example uses cert-manager for certificate management and NGINX ingress with mTLS enforcement. 
can adapt this to Istio or Linkerd if you're using a service mesh.

## Architecture Overview

      Client → Ingress Controller (NGINX) → Service A (mTLS enforced)

  1. Client presents a valid client certificate.
  
  2. NGINX Ingress validates the client certificate using a trusted CA.
  
  3. Service A accepts traffic only from authenticated clients.

### Step-by-Step Setup

1. Install cert-manager
   
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml

2. Create a CA Issuer

```   
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: root-ca
spec:
  ca:
    secretName: root-ca-key-pair
```

3. Generate Server and Client Certificates
```
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: service-a-cert
spec:
  secretName: service-a-tls
  issuerRef:
    name: root-ca
  commonName: service-a.default.svc.cluster.local
  dnsNames:
    - service-a.default.svc.cluster.local
```
yaml
```
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: client-cert
spec:
  secretName: client-tls
  issuerRef:
    name: root-ca
  commonName: trusted-client
```

4. Configure NGINX Ingress for mTLS

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mtls-ingress
  annotations:
    nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
    nginx.ingress.kubernetes.io/auth-tls-secret: "default/root-ca-key-pair"
    nginx.ingress.kubernetes.io/auth-tls-pass-certificate-to-upstream: "true"
spec:
  rules:
    - host: service-a.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-a
                port:
                  number: 443
```
5. Deploy Service A with TLS

```
apiVersion: v1
kind: Service
metadata:
  name: service-a
spec:
  selector:
    app: service-a
  ports:
    - protocol: TCP
      port: 443
      targetPort: 8443
```
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-a
spec:
  template:
    spec:
      containers:
        - name: service-a
          image: your-image
          ports:
            - containerPort: 8443
          volumeMounts:
            - name: tls
              mountPath: /etc/tls
              readOnly: true
      volumes:
        - name: tls
          secret:
            secretName: service-a-tls
```

### Bonus: Audit-Ready Enhancements

🔍 Enable access logs and TLS handshake logs in NGINX.

🔁 Rotate certificates using cert-manager’s renewal policies.

📜 Use Kubernetes NetworkPolicies to restrict traffic to mTLS ingress only.


# mTLS Handshake Flow Across Microservices in Kubernetes

## Purpose

This guide explains how mutual TLS (mTLS) secures service-to-service communication in Kubernetes by enforcing bidirectional authentication using X.509 certificates.

---

## Components Involved

- **Client Pod**: Initiates the request.
- **Ingress Controller (NGINX or Envoy)**: Terminates TLS and validates client cert.
- **Service A Pod**: Receives request, validates upstream identity if needed.
- **cert-manager**: Issues and rotates certificates.
- **CA Issuer**: Root of trust for all certs.

---

## Handshake Flow

1. **Client → Ingress**
   - Client initiates TLS handshake.
   - Presents its client certificate.
   - Ingress validates against trusted CA.

2. **Ingress → Service A**
   - Ingress forwards request with validated identity.
   - Optionally re-establishes mTLS with Service A.
   - Service A validates ingress identity using its own trust store.

3. **Service A → Response**
   - Processes request.
   - Sends encrypted response back through ingress.

---

## Certificate Trust Chain

- All certificates (client, ingress, service) are signed by the same **CA Issuer**.
- cert-manager automates renewal and revocation.
- Trust is enforced via Kubernetes secrets and annotations.

---

## Audit & Observability Tips

- Enable TLS handshake logging in ingress.
- Use Prometheus to monitor TLS metrics.
- Rotate certificates every 30–90 days.
- Enforce NetworkPolicies to restrict non-mTLS traffic.

---

## Optional Enhancements

- Integrate with SPIRE for workload identity.
- Use Istio for automatic mTLS between services.
- Add OPA policies for fine-grained access control.

tegrate with Prometheus/Grafana to monitor TLS metrics.

---
