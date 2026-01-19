<form action="<%=request.getContextPath()%>/LoginServlet" method="post">
    Username: <input type="text" name="username"
               value="<%= request.getAttribute("usernameValue") != null ? request.getAttribute("usernameValue") : "" %>"
               required><br><br>
    Password: <input type="password" name="password" required><br><br>

    <span style="color:red">
        <%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %>
    </span><br>

    <input type="submit" value="Login">
</form>
