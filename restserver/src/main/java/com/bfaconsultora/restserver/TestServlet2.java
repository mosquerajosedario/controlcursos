package com.bfaconsultora.restserver;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class TestServlet2 extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.setStatus(HttpServletResponse.SC_OK);

        PrintWriter pw = response.getWriter();
        pw.println("<h1>Jetty Embedded Servlet</h1>");
        pw.println("<p>Test2 <b>Jetty</b>...</p>");
    }
}
