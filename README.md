# SLaMbda 🤏

## Overview

Learn how to run small language models (SLMs) at scale on [AWS Lambda](https://aws.amazon.com/lambda/) using [function URLs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html) and [response streaming](https://aws.amazon.com/blogs/compute/introducing-aws-lambda-response-streaming/).

## Instructions

1. Run `chmod +x setup.sh && ./setup.sh`

2. Save the URL endpoint (`FUNCTION_URL`).

2. Test it out!

    **cURL**

    ```bash
    curl --no-buffer \
        --aws-sigv4 "aws:amz:$AWS_DEFAULT_REGION:lambda" \
        --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
        -H "x-amz-security-token: $AWS_SESSION_TOKEN" \
        -H "content-type: application/json" \
        -d '{"message": "Explain the theory of relativity."}' \
        $FUNCTION_URL
    ```