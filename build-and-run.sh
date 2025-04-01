#!/bin/bash
set -eo pipefail

# Configuration
IMAGE_NAME="legit"
TAG="arm64"
ECR_REPO=""
AWS_REGION=""
AWS_ACCOUNT_ID=""
FULL_LOCAL_TAG="${IMAGE_NAME}:${TAG}"

# Parse command line args
PUSH_TO_ECR=0
RUN_CONTAINER=0
BUILD=1
HELP=0

for arg in "$@"; do
  case $arg in
    --push)
      PUSH_TO_ECR=1
      ;;
    --run)
      RUN_CONTAINER=1
      ;;
    --no-build)
      BUILD=0
      ;;
    --ecr-repo=*)
      ECR_REPO="${arg#*=}"
      ;;
    --aws-region=*)
      AWS_REGION="${arg#*=}"
      ;;
    --aws-account=*)
      AWS_ACCOUNT_ID="${arg#*=}"
      ;;
    --help)
      HELP=1
      ;;
  esac
done

# Display help
if [ $HELP -eq 1 ]; then
  echo "Legit Docker Build & Run Script"
  echo ""
  echo "Usage: ./build-and-run.sh [options]"
  echo ""
  echo "Options:"
  echo "  --push             Push the image to ECR after building"
  echo "  --run              Run the container after building"
  echo "  --no-build         Skip building the image"
  echo "  --ecr-repo=NAME    Set the ECR repository name"
  echo "  --aws-region=NAME  Set the AWS region"
  echo "  --aws-account=ID   Set the AWS account ID"
  echo "  --help             Display this help message"
  echo ""
  echo "Examples:"
  echo "  ./build-and-run.sh --run                 # Build and run locally"
  echo "  ./build-and-run.sh --push --aws-region=us-east-1 --aws-account=123456789012 --ecr-repo=legit  # Push to ECR"
  exit 0
fi

# Check if we're on ARM64
ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" && "$ARCH" != "aarch64" ]]; then
  echo "⚠️  Warning: You are not on an ARM64 platform (detected: $ARCH)."
  echo "   Building might take longer and require emulation."
  echo "   Consider using an ARM64 platform for optimal performance."
  echo ""
fi

# Build the image
if [ $BUILD -eq 1 ]; then
  echo "🔨 Building Docker image for ARM64..."
  docker build -t $FULL_LOCAL_TAG -f Dockerfile .
  echo "✅ Build complete: $FULL_LOCAL_TAG"
fi

# Push to ECR if requested
if [ $PUSH_TO_ECR -eq 1 ]; then
  if [ -z "$ECR_REPO" ] || [ -z "$AWS_REGION" ] || [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "❌ Error: To push to ECR, you must specify --ecr-repo, --aws-region, and --aws-account"
    exit 1
  fi
  
  ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO"
  ECR_TAG="$ECR_URI:$TAG"
  
  echo "🔄 Logging in to ECR..."
  aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
  
  echo "🏷️  Tagging image for ECR: $ECR_TAG"
  docker tag $FULL_LOCAL_TAG $ECR_TAG
  
  echo "📤 Pushing image to ECR..."
  docker push $ECR_TAG
  
  echo "✅ Successfully pushed to ECR: $ECR_TAG"
fi

# Run the container if requested
if [ $RUN_CONTAINER -eq 1 ]; then
  echo "🚀 Running container..."
  
  # Create the tmp directory if it doesn't exist
  mkdir -p ./tests/tmp
  
  docker run -it --rm \
    -v "$(pwd):/workspace" \
    -w /workspace \
    --name legit-dev \
    $FULL_LOCAL_TAG
  
  echo "✅ Container exited."
fi

echo "🎉 Done!"

