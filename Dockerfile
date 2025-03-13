FROM python:3.9-alpine

ARG FLASK_APP
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_DB

ENV FLASK_APP=${FLASK_APP}
ENV DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db/${POSTGRES_DB}

COPY requirements.txt requirements.txt

RUN apk add --no-cache \
    build-base \
    libffi-dev \
    bash \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn pymysql cryptography \
    && apk del build-base libffi-dev

RUN adduser -D myuser

RUN mkdir logs && chown -R myuser:myuser logs

COPY app app
COPY migrations migrations
COPY microblog.py config.py boot.sh ./

RUN chmod +x boot.sh

RUN chown -R myuser:myuser app/translations

USER myuser

RUN flask translate compile

EXPOSE 5000

ENTRYPOINT ["./boot.sh"]