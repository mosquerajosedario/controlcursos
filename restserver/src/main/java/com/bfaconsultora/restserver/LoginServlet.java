package com.bfaconsultora.restserver;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.*;

import com.bfaconsultora.dbconnector.PGConnector;

public class LoginServlet extends HttpServlet {
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		PGConnector pgConnector = new PGConnector("localhost", "test");
		
		JSONObject loginCredentials = new JSONObject(request.getParameter("loginCredentials"));
		
		String username = loginCredentials.getString("username");
		String password = loginCredentials.getString("password");
		
		response.setContentType("application/json; charset=UTF-8");
		response.setStatus(HttpServletResponse.SC_OK);
		
		PrintWriter pw = response.getWriter();
		
		JSONObject loginStatus = new JSONObject();

		if(pgConnector.testLoginCredentials(username, password)) {
			loginStatus.put("connected", true);
		} else {
			loginStatus.put("connected", false);
		}
		
		pw.println(loginStatus.toString());
	}
}
