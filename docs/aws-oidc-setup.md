# AWS OIDC Setup for GitHub Actions

## 1. OIDCプロバイダーの作成

AWS Console → IAM → Identity providers → Add provider

- **Provider type**: OpenID Connect
- **Provider URL**: `https://token.actions.githubusercontent.com`
- **Audience**: `sts.amazonaws.com`

## 2. IAMロールの信頼ポリシー

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

## 3. 必要な権限ポリシー

### Option 1: Administrator権限（推奨 - 開発/テスト環境）

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
```

**利点:**
- あらゆるAWSサービスへのフルアクセス
- 新しいリソースタイプの追加時も権限変更不要
- 開発効率が高い
- Terraformのplan/applyで権限エラーが発生しない

### Option 2: 制限付き権限（本番環境推奨）

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "ecs:*",
        "iam:*",
        "lambda:*",
        "logs:*",
        "s3:*",
        "dynamodb:*",
        "cloudwatch:*",
        "sns:*",
        "ssm:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "route53:*",
        "cloudformation:*",
        "sts:AssumeRole",
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    }
  ]
}
```

**推奨:** 開発・テスト環境では**Administrator権限**を使用し、本番環境では必要最小限の権限に制限することを検討してください。

## 4. AWS CLI / Terraform での作成

### OIDCプロバイダー作成
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com
```

### IAMロール作成

```bash
# 信頼ポリシーファイルを作成
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

# Administrator権限をアタッチ（推奨）
aws iam attach-role-policy \
  --role-name minecraft-test-github-actions \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# または、制限付き権限を使用する場合は、カスタムポリシーを作成してアタッチ
# aws iam create-policy \
#   --policy-name TerragruntRestrictedPolicy \
#   --policy-document file://restricted-policy.json
# aws iam attach-role-policy \
#   --role-name minecraft-test-github-actions \
#   --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/TerragruntRestrictedPolicy
```

## 5. 重要なポイント

1. **リポジトリ名の一致**: `ShotaroMatsuya/minecraft-server-automation` が正確である必要があります
2. **ワイルドカード使用**: `repo:ShotaroMatsuya/minecraft-server-automation:*` でリポジトリの全てのブランチとPRを許可
3. **Account ID**: `YOUR_ACCOUNT_ID` を実際のAWSアカウントIDに置換
4. **最小権限の原則**: 実際に必要な権限のみを付与
5. **セキュリティ**: ワイルドカードを使用することで、特定のブランチに限定せずリポジトリ全体を信頼

### 信頼ポリシーの変更理由
- **以前**: 特定のブランチ（main, pull_request）のみを許可
- **推奨**: `repo:リポジトリ名:*` でリポジトリ全体を許可
- **利点**: 新しいブランチでも自動的に動作し、メンテナンスが不要

## 6. 検証方法

作成後、以下のコマンドで確認：

```bash
# OIDCプロバイダー確認
aws iam list-open-id-connect-providers

# IAMロール確認
aws iam get-role --role-name minecraft-test-github-actions
```
