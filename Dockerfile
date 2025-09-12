FROM docker:stable
COPY start-mongodb.sh /start-mongodb.sh
COPY stop-mongodb.sh /stop-mongodb.sh
RUN chmod +x /start-mongodb.sh /stop-mongodb.sh
ENTRYPOINT ["/start-mongodb.sh"]
