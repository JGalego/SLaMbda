FROM public.ecr.aws/lambda/nodejs:20

ARG MODEL_NAME
ENV MODEL_NAME=${MODEL_NAME}

RUN curl -L "https://gpt4all.io/models/gguf/${MODEL_NAME}" \
         -o "${LAMBDA_TASK_ROOT}/${MODEL_NAME}" && \
    curl -L https://gpt4all.io/models/models3.json \
         -o "${LAMBDA_TASK_ROOT}/models3.json"

COPY index.mjs package.json ${LAMBDA_TASK_ROOT}/

RUN npm install

CMD [ "index.handler" ]