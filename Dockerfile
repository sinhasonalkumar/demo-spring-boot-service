FROM adoptopenjdk:11-jre-hotspot as builder
WORKDIR application
ARG JAR_FILE=target/demo-spring-boot-service.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM openjdk:11-jre-slim

RUN groupadd --gid 5000 appUser \
    && useradd --home-dir /home/appUser --create-home --uid 5000 \
        --gid 5000 --shell /bin/sh --skel /dev/null appUser
                
EXPOSE 8080

WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./

USER appUser:appUser
        
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]