# 使用

## 镜像编译

```bash
cd /admission-webhook-example
export DOCKER_USER=sunnoy
bash -x build
```

## 服务端证书签发

- 使用openssl创建服务端证书的key
- 使用openssl创建服务端证书签发请求 server.csr
- 使用k8s中CertificateSigningRequest资源对象使用k8s中的ca来签发这个服务端证书
- 证书签发完成后将会存储在CertificateSigningRequest的status.certificate里面
- 创建secret里面包含cert和key让后让webhook的deployment使用

## 签发的ca获取

- apiserver需要通过https访问webhook，因此apiserver需要ca
- ca

kubectl label namespace default admission-webhook-example=enabled

export CA_FBUNDLED=$(cat ca.pem | base64)










# Kubernetes Admission Webhook example

详细文档
[https://www.qikqiak.com/post/k8s-admission-webhook/
](详细文档)
This tutoral shows how to build and deploy an [AdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#admission-webhooks).

The Kubernetes [documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/) contains a common set of recommended labels that allows tools to work interoperably, describing objects in a common manner that all tools can understand. In addition to supporting tooling, the recommended labels describe applications in a way that can be queried.
In our validating webhook example we make these labels required on deployments and services, so this webhook rejects every deployment and every service that doesn’t have these labels set. The mutating webhook in the example adds all the missing required labels with `not_available` set as the value.

## Prerequisites

Kubernetes 1.9.0 or above with the `admissionregistration.k8s.io/v1beta1` API enabled. Verify that by the following command:
```
kubectl api-versions | grep admissionregistration.k8s.io/v1beta1
```
The result should be:
```
admissionregistration.k8s.io/v1beta1
```

In addition, the `MutatingAdmissionWebhook` and `ValidatingAdmissionWebhook` admission controllers should be added and listed in the correct order in the admission-control flag of kube-apiserver.

## Build

Build and push docker image
   
```
./build
```

## How does it work?

We have a blog post that explains webhooks in depth with the help of this example. Check [it](https://www.qikqiak.com/post/k8s-admission-webhook/) out!

