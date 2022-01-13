<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="home.aspx.cs" Inherits="EMRPortal.home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            $("#<%= lstFacilities.ClientID %>").select2();
        });

        $(function () {
            $(".js-example-placeholder-single").select2({
                placeholder: "Select",
                allowClear: true
            });
        });

        $(function () {
            $("#<%= txtStartDate.ClientID %>").datepicker({
                changeMonth: true,
                changeYear: true
            });
        });

        $(function () {
            $("#<%= txtEndDate.ClientID %>").datepicker({
                changeMonth: true,
                changeYear: true
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="row">
        <ol class="breadcrumb">
            <li><a href="#"><em class="fa fa-home"></em></a></li>
            <li class="active">
                <asp:Label ID="lblBreadcrumb" runat="server" Text="General Queries"></asp:Label></li>
        </ol>
    </div>
    <!--/.row-->
    <div class="row">
        <div class="col-lg-12">
            <h1 class="page-header">
                <asp:Label ID="lblTitle" runat="server" Text="General Queries"></asp:Label></h1>
        </div>
    </div>
    <!--/.row-->
    <div class="row">
        <div class="col-md-6">
            <div class="form-group">
                <label>
                    Select Query: </label>
                <asp:DropDownList ID="ddlQuery" runat="server" CssClass="form-control" 
                    AutoPostBack="true" required 
                    onselectedindexchanged="ddlQuery_SelectedIndexChanged">
                </asp:DropDownList>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6" runat="server" id="divFromDate">
            <div class="form-group">
                <label>
                    Start Date:</label>
                <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" required />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6" runat="server" id="divToDate">
            <div class="form-group">
                <label>
                    End Date:</label>
                <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" required />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6">
            <div class="form-group">
                <label>
                    Select Facilities: </label>
                <asp:ListBox ID="lstFacilities" runat="server" SelectionMode="Multiple" data-placeholder="Select facilities"
                    CssClass="form-control js-example-placeholder-single" required></asp:ListBox>
            </div>
        </div>
    </div>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="row">
                <div class="col-md-6">
                    <asp:Button ID="btnLoad" runat="server" Text="Load Data" CssClass="btn btn-success btn-lg btn-block"
                        OnClick="btnLoad_Click" />
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <asp:Timer ID="Timer1" runat="server" Interval="200" Enabled="false" OnTick="Timer1_Tick">
                    </asp:Timer>
                    <asp:Label ID="lbProgress" runat="server" Text=""></asp:Label><br />
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
