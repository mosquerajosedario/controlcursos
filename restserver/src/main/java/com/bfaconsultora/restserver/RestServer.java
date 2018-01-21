package com.bfaconsultora.restserver;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletHandler;

public class RestServer {

    public static void main(String[] args) throws Exception {

        Server server = new Server(8080);

        ServletHandler handler = new ServletHandler();
        handler.addServletWithMapping(TestServlet.class, "/*");

        server.setHandler(handler);

        server.start();
        server.join();
    }
}
