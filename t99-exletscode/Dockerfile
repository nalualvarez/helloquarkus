FROM atf.intranet.bb.com.br:5001/bb/dev/dev-java:11.0.15

COPY --chown=185 target/quarkus-app/*.jar /deployments/
COPY --chown=185 target/quarkus-app/lib /deployments/lib/
COPY --chown=185 target/quarkus-app/app /deployments/app/
COPY --chown=185 target/quarkus-app/quarkus /deployments/quarkus/

ENTRYPOINT ["java", "-jar", "/deployments/quarkus-run.jar"]