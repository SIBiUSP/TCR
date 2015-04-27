<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Home page JSP
  -
  - Attributes:
  -    communities - Community[] all communities in DSpace
  -    recent.submissions - RecetSubmissions
--%>

<%@page import="org.dspace.core.Utils"%>
<%@page import="org.dspace.content.Bitstream"%>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.io.File" %>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.app.webui.components.RecentSubmissions" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.core.NewsManager" %>
<%@ page import="org.dspace.browse.ItemCounter" %>
<%@ page import="org.dspace.content.Metadatum" %>
<%@ page import="org.dspace.content.Item" %>
<%@ page import="org.apache.commons.lang.StringUtils"%>

<%
    Community[] communities = (Community[]) request.getAttribute("communities");

    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    Locale sessionLocale = UIUtil.getSessionLocale(request);
    Config.set(request.getSession(), Config.FMT_LOCALE, sessionLocale);
    String topNews = NewsManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-top.html"));
    String sideNews = NewsManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-side.html"));

    boolean feedEnabled = ConfigurationManager.getBooleanProperty("webui.feed.enable");
    String feedData = "NONE";
    if (feedEnabled) {
        feedData = "ALL:" + ConfigurationManager.getProperty("webui.feed.formats");
    }
    
    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));

    RecentSubmissions submissions = (RecentSubmissions) request.getAttribute("recent.submissions");
%>
<dspace:layout locbar="nolink" titlekey="jsp.home.title" feedData="<%= feedData%>">
    <div class="row">
        <div class="col-md-8">
            <div class="jumbotron">
                <div class="box">
                    <h3 class="chamada">BDTA</h3>
                    <p class="espaco">A Biblioteca Digital de Trabalhos Acadêmicos da Universidade de São Paulo (BDTA).</p>
                </div>

            </div>

            <%
                if (submissions != null && submissions.count() > 0) {
            %>
            <div class="panel">
                <div class="panel-heading">
                    <h3><fmt:message key="jsp.collection-home.recentsub"/>
                        <%
                            if (feedEnabled) {
                                String[] fmts = feedData.substring(feedData.indexOf(':') + 1).split(",");
                                String icon = null;
                                int width = 0;
                                for (int j = 0; j < fmts.length; j++) {
                                    if ("rss_1.0".equals(fmts[j])) {
                                        icon = "rss1.gif";
                                        width = 80;
                                    } else if ("rss_2.0".equals(fmts[j])) {
                                        icon = "rss2.gif";
                                        width = 80;
                                    } else {
                                        icon = "rss.gif";
                                        width = 36;
                                    }
                        %>
                        <a href="<%= request.getContextPath()%>/feed/<%= fmts[j]%>/site"><img src="<%= request.getContextPath()%>/image/<%= icon%>" alt="RSS Feed" width="<%= width%>" height="15" vspace="3" border="0" /></a>
                            <%
                                    }
                                }
                            %>
                    </h3>
                </div>

                    

		    <%
		    boolean first = true;
		    for (Item item : submissions.getRecentSubmissions())
		    {
		        Metadatum[] dcv = item.getMetadata("dc", "title", null, Item.ANY);
		        String displayTitle = "Untitled";
		        if (dcv != null & dcv.length > 0)
		        {
		            displayTitle = Utils.addEntities(dcv[0].value);
		        }
		        dcv = item.getMetadata("dc", "contributor", "author", Item.ANY);
		        String displayAuthor = "";
		        if (dcv != null & dcv.length > 0)
		        {
		            displayAuthor = Utils.addEntities(dcv[0].value);
		        }
		        dcv = item.getMetadata("dc", "description", "abstract", Item.ANY);
		        String displayAbstract = "";
		        if (dcv != null & dcv.length > 0)
		        {
		            displayAbstract = Utils.addEntities(dcv[0].value);
		        }
		        dcv = item.getMetadata("usp", "unidade", "sigla", Item.ANY);
		        String displaySigla = "";
		        if (dcv != null & dcv.length > 0)
		        {
		            displaySigla = Utils.addEntities(dcv[0].value);
		        }
		%>
                
                <div class="media padding15">
                    <a class="pull-left" href="#">
                        <img class="pull-left" src="image/logosusp/<%=StringUtils.abbreviate(displaySigla, 10).toLowerCase()%>.jpg" height="32px">
                    </a>    
                    
                    
                    <div class="media-body col-md-11">
                        <a href="<%= request.getContextPath()%>/handle/<%=item.getHandle()%>"><h4 class="media-heading"><%=StringUtils.abbreviate(displayTitle, 400)%>﻿</h4></a>
                        <p><%= StringUtils.abbreviate(displayAuthor, 100) %></p>
                        <p><%= StringUtils.abbreviate(displayAbstract, 500) %></p>
		    </div>
		</div>
		<%
				first = false;
		     }
		%>
		  
                    
            <%
                }
            %>
                    
                 
                    
            </div></div>
        
<%--     
<div class="row">
    <%
    if (communities != null && communities.length != 0)
    {
    %>
    
    <div class="col-md-5">		
        <h3><fmt:message key="jsp.home.com1"/></h3>
        <p><fmt:message key="jsp.home.com2"/></p>
        <div class="list-group">
            <%
                    boolean showLogos = ConfigurationManager.getBooleanProperty("jspui.home-page.logos", true);
                for (int i = 0; i < communities.length; i++)
                {
            %><div class="list-group-item row">
                <%  
                                Bitstream logo = communities[i].getLogo();
                                if (showLogos && logo != null) { %>
                <div class="col-md-4">
                    <img alt="Logo" class="img-responsive" src="<%= request.getContextPath() %>/retrieve/<%= logo.getID() %>" /> 
                </div>
                <div class="col-md-9">
                    <% } else { %>
                    <div class="col-md-12">
                        <% }  %>		
                        <h4 class="list-group-item-heading"><a href="<%= request.getContextPath() %>/handle/<%= communities[i].getHandle() %>"><%= communities[i].getMetadata("name") %></a>
                            <%
                                    if (ConfigurationManager.getBooleanProperty("webui.strengths.show"))
                                    {
                            %>
                            <span class="badge pull-right"><%= ic.getCount(communities[i]) %></span>
                            <%
                                    }

                            %>
                        </h4>
                        <p><%= communities[i].getMetadata("short_description") %></p>
                    </div>
                </div>                            
                <%
                    }
                %>
            </div>
        </div>
        <%
        }
        %>
        <%
        int discovery_panel_cols = 7;
        int discovery_facet_cols = 5;
        %>
        <%@ include file="discovery/static-sidebar-facet.jsp" %>
    </div>


        <%@ include file="discovery/static-tagcloud-facet.jsp" %>

 </div>
--%>
            
<div class="col-md-4">

    <div class="panel text-justify">
        <div class="panel-heading">
            <h3><fmt:message key="jsp.home.com1"/></h3>
        </div>
         
        
        
        

    <%
    if (communities != null && communities.length != 0)
    {
    %>
    
 		
            <div class="panel">

                <div class="panel-body">
            <%
                    boolean showLogos = ConfigurationManager.getBooleanProperty("jspui.home-page.logos", true);
                for (int i = 0; i < communities.length; i++)
                {
            %>
                <%  
                                Bitstream logo = communities[i].getLogo();
                                if (showLogos && logo != null) { %>
                <div class="spamimage inline"><a href="<%= request.getContextPath() %>/handle/<%= communities[i].getHandle() %>"><img alt="Logo" class="img-responsive" src="<%= request.getContextPath() %>/retrieve/<%= logo.getID() %>" title="<%= communities[i].getMetadata("name") %>" /> <span class="spantext badge"><%= ic.getCount(communities[i]) %></span></a></div>
               
                    <% } else { %>
                 
                        		
                        <div class="spamimage inline"><a href="<%= request.getContextPath() %>/handle/<%= communities[i].getHandle() %>"><%= communities[i].getMetadata("name") %><span class="badge pull-right"><%= ic.getCount(communities[i]) %></span></a></div>
                        <% }  %>
                      
                    
                                          
                <%
                    }
                %>
            
        
        <%
        }
        %>


        </div>
    </div></div>
        
        
<%--   
        
        
        <div class="row tooltip-demo table-responsive">
            <table class="table-borderless table-condensed">
                <tr>
                <th><a href="handle/BDPI/1315"><img class="img-responsive" src="image/logosusp/cebimar.jpg" title="Centro de Biologia Marinha - CEBIMar"></a></th>
                <th><a href="handle/BDPI/1"><img class="img-responsive" src="image/logosusp/cena.jpg" title="Centro de Energia Nuclear na Agricultura - CENA"></a></th>
                <th><a href="handle/BDPI/1365"><img class="img-responsive" src="image/logosusp/each.jpg" title="Escola de Artes, Ciências e Humanidades - EACH"></a></th>
                <th><a href="handle/BDPI/22"><img class="img-responsive" src="image/logosusp/eca.jpg" title="Escola de Comunicações e Artes - ECA"></a></th>
                <th><a href="handle/BDPI/1360"><img class="img-responsive" src="image/logosusp/eeferp.jpg" title="Escola de Educação Física e Esporte de Ribeirão Preto - EEFERP"></a></th>
                </tr><tr>
                <th><a href="handle/BDPI/94"><img class="img-responsive" src="image/logosusp/eefe.jpg" title="Escola de Educação Física e Esporte - EEFE"></a></th>
                <th><a href="handle/BDPI/115"><img class="img-responsive" src="image/logosusp/eerp.jpg" title="Escola de Enfermagem de Ribeirão Preto - EERP"></a></th>
                <th><a href="handle/TCR/12"><img class="img-responsive" src="image/logosusp/ee.jpg" title="Escola de Enfermagem - EE"></a></th>
                <th><a href="handle/BDPI/136"><img class="img-responsive" src="image/logosusp/eel.jpg" title="Escola de Engenharia de Lorena - EEL"></a></th>
                <th><a href="handle/TCR/1211"><img class="img-responsive" src="image/logosusp/eesc.jpg" title="Escola de Engenharia de São Carlos - EESC"></a></th>
                </tr><tr>
                <th><a href="handle/BDPI/213"><img class="img-responsive" src="image/logosusp/ep.jpg" title="Escola Politécnica - EP"></a></th>
                <th><a href="handle/BDPI/294"><img class="img-responsive" src="image/logosusp/esalq.jpg" title="Escola Superior de Agricultura Luiz de Queiroz - ESALQ"></a></th>
                <th><a href="handle/BDPI/360"><img class="img-responsive" src="image/logosusp/fau.jpg" title="Faculdade de Arquitetura e Urbanismo - FAU"></a></th> 
                <th><a href="handle/BDPI/407"><img class="img-responsive" src="image/logosusp/fcfrp.jpg" title="Faculdade de Ciências Farmacêuticas de Ribeirão Preto - FCFRP"></a></th>
                <th><a href="handle/TCR/18"><img class="img-responsive" src="image/logosusp/fcf.jpg" title="Faculdade de Ciências Farmacêuticas - FCF"></a></th>
                </tr><tr>
                <th><a href="handle/TCR/2490"><img class="img-responsive" src="image/logosusp/fdrp.jpg" title="Faculdade de Direito de Ribeirão Preto - FDRP"></a></th>
                <th><a href="handle/BDPI/428"><img class="img-responsive" src="image/logosusp/fd.jpg" title="Faculdade de Direito - FD"></a></th>
                <th><a href="handle/TCR/2492"><img class="img-responsive" src="image/logosusp/fearp.jpg" title="Faculdade de Economia, Administração e Contabilidade de Ribeirão Preto - FEARP"></a></th>
                <th><a href="handle/BDPI/521"><img class="img-responsive" src="image/logosusp/fea.jpg" title="Faculdade de Economia, Administração e Contabilidade - FEA"></a></th>
                <th><a href="handle/BDPI/500"><img class="img-responsive" src="image/logosusp/fe.jpg" title="Faculdade de Educação - FE"></a></th>
                </tr><tr>
                <th><a href="handle/BDPI/1248"><img class="img-responsive" src="image/logosusp/ffclrp.jpg" title="Faculdade de Filosofia, Ciências e Letras de Ribeirão Preto - FFCLRP"></a></th>
                <th><a href="handle/BDPI/563"><img class="img-responsive" src="image/logosusp/fflch.jpg" title="Faculdade de Filosofia, Letras e Ciências Humanas - FFLCH"></a></th>
                <th><a href="handle/TCR/13"><img class="img-responsive" src="image/logosusp/fm.jpg" title="Faculdade de Medicina - FM"></a></th>
                <th><a href="handle/TCR/14"><img class="img-responsive" src="image/logosusp/fmrp.jpg" title="Faculdade de Medicina de Ribeirão Preto - FMRP"></a></th> 
                <th><a href="handle/TCR/15"><img class="img-responsive" src="image/logosusp/fmvz.jpg" title="Faculdade de Medicina Veterinária e Zootecnia - FMVZ"></a></th>
                </tr><tr>
                <th><a href="handle/BDPI/878"><img class="img-responsive" src="image/logosusp/fob.jpg" title="Faculdade de Odontologia de Bauru - FOB"></a></th>
                <th><a href="handle/TCR/17"><img class="img-responsive" src="image/logosusp/fo.jpg" title="Faculdade de Odontologia - FO"></a></th>
                <th><a href="handle/TCR/16"><img class="img-responsive" src="image/logosusp/forp.jpg" title="Faculdade de Odontologia de Ribeirão Preto - FORP"></a></th>
                <th><a href="handle/BDPI/914"><img class="img-responsive" src="image/logosusp/fsp.jpg" title="Faculdade de Saúde Pública - FSP"></a></th>
                <th><a href="handle/TCR/19"><img class="img-responsive" src="image/logosusp/fzea.jpg" title="Faculdade de Zootecnia e Engenharia de Alimentos - FZEA"></a></th>
                </tr><tr>
                <th><a href="handle/TCR/11"><img class="img-responsive" src="image/logosusp/hrac.jpg" title="Hospital de Reabilitação de Anomalias Craniofaciais - HRAC"></a></th>
                <th><a href="handle/BDPI/1330"><img class="img-responsive" src="image/logosusp/hu.jpg" title="Hospital Universitário - HU"></a></th>
                <th><a href="handle/BDPI/32492"><img class="img-responsive" src="image/logosusp/iau.jpg" title="Instituto de Arquitetura e Urbanismo de São Carlos - IAU"></a></th>
                <th><a href="handle/BDPI/966"><img class="img-responsive" src="image/logosusp/iag.jpg" title="Instituto de Astronomia, Geofísica e Ciências Atmosféricas - IAG"></a></th>      
                <th><a href="handle/BDPI/987"><img class="img-responsive" src="image/logosusp/ib.jpg" title="Instituto de Biociências - IB"></a></th>
                </tr><tr>
                <th><a href="handle/BDPI/1018"><img class="img-responsive" src="image/logosusp/icb.jpg" title="Instituto de Ciências Biomédicas - ICB"></a></th>
                <th><a href="handle/BDPI/1059"><img class="img-responsive" src="image/logosusp/icmc.jpg" title="Instituto de Ciências Matemáticas e de Computação - ICMC"></a></th>
                <th><a href="handle/BDPI/1320"><img class="img-responsive" src="image/logosusp/iee.jpg" title="Instituto de Eletrotécnica e Energia - IEE"></a></th>
                <th><a href="handle/BDPI/1350"><img class="img-responsive" src="image/logosusp/ieb.jpg" title="Instituto de Estudos Brasileiros - IEB"></a></th>
                <th><a href="handle/BDPI/1116"><img class="img-responsive" src="image/logosusp/ifsc.jpg" title="Instituto de Física de São Carlos - IFSC"></a></th>
                </tr><tr>
                <th><a href="handle/BDPI/1080"><img class="img-responsive" src="image/logosusp/if.jpg" title="Instituto de Física - IF"></a></th>
                <th><a href="handle/BDPI/1132"><img class="img-responsive" src="image/logosusp/igc.jpg" title="Instituto de Geociências - IGc"></a></th>
                <th><a href="handle/BDPI/1148"><img class="img-responsive" src="image/logosusp/ime.jpg" title="Instituto de Matemática e Estatística - IME"></a></th>
                <th><a href="handle/BDPI/32490"><img class="img-responsive" src="image/logosusp/imt.jpg" title="Instituto de Medicina Tropical de São Paulo - IMT"></a></th>
                <th><a href="handle/BDPI/1190"><img class="img-responsive" src="image/logosusp/ip.jpg" title="Instituto de Psicologia - IP"></a></th>
                </tr><tr>
                <th><a href="handle/BDPI/1232"><img class="img-responsive" src="image/logosusp/iqsc.jpg" title="Instituto de Química de São Carlos - IQSC"></a></th>
                <th><a href="handle/BDPI/1216"><img class="img-responsive" src="image/logosusp/iq.jpg" title="Instituto de Química - IQ"></a></th>
                <th><a href="handle/BDPI/16894"><img class="img-responsive" src="image/logosusp/iri.jpg" title="Instituto de Relações Internacionais - IRI"></a></th>
                <th><a href="handle/BDPI/1174"><img class="img-responsive" src="image/logosusp/io.jpg" title="Instituto Oceanográfico - IO"></a></th>
                <!-- <th><a href="handle/BDPI/1355"><img class="img-responsive" src="image/logosusp/mae.jpg" title="Museu de Arqueologia e Etnologia - MAE"></a></th>
                <th><a href="handle/BDPI/1335"><img class="img-responsive" src="image/logosusp/mac.jpg" title="Museu de Arte Contemporânea - MAC"></a></th>
                <th><a href="handle/BDPI/1345"><img class="img-responsive" src="image/logosusp/mz.jpg" title="Museu de Zoologia - MZ"></a></th>
                <th><a href="handle/BDPI/1340"><img class="img-responsive" src="image/logosusp/mp.jpg" title="Museu Paulista - MP"></a></th> -->
                <!-- <th><a href="handle/BDPI/1370"><img class="img-responsive" src="image/logosusp/sibi.jpg" title="Sistema Integrado de Bibliotecas - SIBi"></a></th> -->
                </tr>
            </table>
        </div> --%>
   
    <div class="panel">
        <div class="panel-body pull-center">
            <div class="addthis_toolbox addthis_default_style addthis_32x32_style" style="width:350px;height:70px">
                <a class="addthis_button_facebook_like" fb:like:layout="box_count" fb:like:action="recommend"></a>
                <a class="addthis_button_tweet" tw:count="vertical"></a>
                <a class="addthis_button_google_plusone" g:plusone:size="tall"></a>
                <a class="addthis_button_linkedin_counter" li:counter="top"></a>
                <a class="addthis_button_compact"></a>
            </div>
            <script async="async" defer="true" type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-4f9b00617c1df207" >
                & #160;
            </script>
        </div>
    </div>


<div class="row text-center">
    <div class="col-lg-12">
        <span class="glyphicon glyphicon-floppy-open iconbg"></span>
        <h3>Como depositar</h3>
        <p>Donec sed odio dui. Etiam porta sem malesuada magna mollis euismod. Nullam id dolor id nibh ultricies vehicula ut id elit. Morbi leo risus, porta ac consectetur ac, vestibulum at eros. Praesent commodo cursus magna.</p>
        <p><a class="btn btn-primary pull-right" href="#" role="button">Saiba mais »</a></p>
        </br></br>
    </div>
    <!-- /.col-lg-4 -->
    <div class="col-lg-12">
        <span class="glyphicon glyphicon-comment iconbg"></span>
        <h3>Como citar</h3>
        <p>Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Cras mattis consectetur purus sit amet fermentum. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh.</p>
        <p><a class="btn btn-primary pull-right" href="#" role="button">Saiba mais »</a>
        </p>
        </br></br>
    </div>
    <!-- /.col-lg-4 -->
</div>
</div>

</dspace:layout>
