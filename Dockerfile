FROM public.ecr.aws/docker/library/docker:stable
COPY start-mongodb.sh /start-mongodb.sh
RUN chmod +x /start-mongodb.sh
ENTRYPOINT ["/start-mongodb.sh"]
