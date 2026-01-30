package com.onlineexam.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Change "online_exam" to your actual database name
    private static final String URL = "jdbc:postgresql://localhost:5432/online_exam";
    private static final String USER = "postgres"; // your PostgreSQL username
    private static final String PASSWORD = "student123"; // your PostgreSQL password

    static {
        try {
            Class.forName("org.postgresql.Driver"); // load driver
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
