FROM python:3.7

RUN useradd flask
WORKDIR /home/flask
ADD . .

RUN apt-get update && apt-get install -y dos2unix && \
    dos2unix app.py test.py && \
    apt-get remove -y dos2unix && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN pip install -r requirements.txt
RUN chmod a+x app.py test.py && \
    chown -R flask:flask ./

ENV FLASK_APP=app.py
EXPOSE 5000
USER flask
CMD ["./app.py"]