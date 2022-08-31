package br.com.bb.t99;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.CoreMatchers.containsString;

@QuarkusTest
public class HelloWorldResourceTest {

    @Test
    public void testHelloEndpoint() {
        given()
                .when().get("/hello")
                .then()
                .statusCode(200)
                .body(containsString("Hello!") );
    }

}