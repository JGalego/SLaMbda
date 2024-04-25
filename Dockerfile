FROM public.ecr.aws/lambda/nodejs:20

COPY *.gguf ${LAMBDA_TASK_ROOT}
COPY index.mjs package.json models3.json ${LAMBDA_TASK_ROOT}
RUN npm install

CMD [ "index.handler" ]