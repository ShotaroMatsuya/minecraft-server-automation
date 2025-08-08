# AWS OIDC Setup for GitHub Actions

## 1. OIDCプロバイダーの作成

AWS Console → IAM → Identity providers → Add provider

- **Provider type**: OpenID Connect
- **Provider URL**: `https://token.actions.githubusercontent.com`
- **Audience**: `sts.amazonaws.com`

## 2. IAMロール作成

### 信頼ポリシー

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:ShotaroMatsuya/minecraft-server-automation:*"
        }
      }
    }
  ]
}
```

### 権限

AdministratorAccessをアタッチ

## 3. AWS CLI での作成

```bash
# OIDCプロバイダー作成
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com

# 信頼ポリシーファイル作成
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:ShotaroMatsuya/minecraft-server-automation:*"
        }
      }
    }
  ]
}
EOF

# IAMロール作成
aws iam create-role \
  --role-name minecraft-test-github-actions \
  --assume-role-policy-document file://trust-policy.json

# Administrator権限をアタッチ
aws iam attach-role-policy \
  --role-name minecraft-test-github-actions \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```
