FROM public.ecr.aws/lambda/nodejs:20

ARG model_name=gpt4all-falcon-newbpe-q4_0.gguf
ENV MODEL_NAME=${model_name}

RUN curl -L https://gpt4all.io/models/gguf/${MODEL_NAME} \
         -o ${LAMBDA_TASK_ROOT}/${MODEL_NAME} && \
    curl -L https://gpt4all.io/models/models3.json \
	     -o ./models3.json

COPY index.mjs package.json models3.json ${LAMBDA_TASK_ROOT}

RUN npm install

CMD [ "index.handler" ]