<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="Tos.FoodProcs.Web.Error" 
 ClientIDMode="Static" EnableViewState="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=8" />
    <title>Error</title>
    <link media="all" rel="stylesheet" href="<%=ResolveUrl("~/Styles/style.css") %>" type="text/css" />
    <style type="text/css">
        :root { --theme-color: <%= colorMenuBar %>; }
    </style>
    <style type="text/css">
        .header-container {
          height: 40px;
          background-image: url('/Styles/images/logo.png');
          background-position-x: 0px;
          background-repeat: no-repeat;
          z-index: 2;
          background-color: var(--theme-color);
          position: relative;
        }
        
        .container {
            margin: 40px;
        }
        
        pre {
            overflow: auto;
        }
    </style>
</head>
<body>
    <header>
       <div class="header-container">
       </div>
    </header>
    <div class="container">
        <h2 id="messageTitle" runat="server"></h2>
        <p id="message" runat="server">
        </p>
        <pre id="stacktrace" runat="server"></pre>
    </div>
</body>
</html>
