<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:atom="http://www.w3.org/2005/Atom"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:planet="http://planet.intertwingly.net/"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="atom planet xhtml">

  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:param name="page-title" select="'Subscriptions'"/>
  <xsl:include href="partials/head.html.xslt" />
  <xsl:include href="partials/header.html.xslt" />
  <xsl:include href="partials/sidebar.html.xslt" />

  <xsl:template match="atom:feed">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
    <html xmlns="http://www.w3.org/1999/xhtml">

      <!-- head -->
      <head>
      <xsl:call-template name="head">
        <xsl:with-param name="page-title" select="$page-title"/>
      </xsl:call-template>
      </head>

      <body>
        <xsl:call-template name="header"/>
        <div class="main-container">
          <div class='main-content'>
            <h2>Subscriptions</h2>
            <ul class='subscriptions'>
              <xsl:for-each select="planet:source">
                <xsl:sort select="planet:name"/>
                <xsl:variable name="id" select="atom:id"/>
                <xsl:variable name="posts"
                  select="/atom:feed/atom:entry[atom:source/atom:id = $id]"/>
                <li>
                  <!-- icon -->
                  <a title="subscribe">
                    <xsl:choose>
                      <xsl:when test="planet:http_location">
                        <xsl:attribute name="href">
                          <xsl:value-of select="planet:http_location"/>
                        </xsl:attribute>
                      </xsl:when>
                      <xsl:when test="atom:link[@rel='self']/@href">
                        <xsl:attribute name="href">
                          <xsl:value-of select="atom:link[@rel='self']/@href"/>
                        </xsl:attribute>
                      </xsl:when>
                    </xsl:choose>
                    <img src="assets/img/feed.svg" width="10" height="10" alt="" />
                  </a>
                  <xsl:text> </xsl:text>

                  <!-- name -->
                  <a>
                    <xsl:if test="atom:link[@rel='alternate']/@href">
                      <xsl:attribute name="href">
                        <xsl:value-of select="atom:link[@rel='alternate']/@href"/>
                      </xsl:attribute>
                    </xsl:if>

                    <xsl:choose>
                      <xsl:when test="planet:message">
                        <xsl:attribute name="class">
                          <xsl:if test="$posts">active message</xsl:if>
                          <xsl:if test="not($posts)">message</xsl:if>
                        </xsl:attribute>
                        <xsl:attribute name="title">
                          <xsl:value-of select="planet:message"/>
                        </xsl:attribute>
                      </xsl:when>
                      <xsl:when test="atom:title">
                        <xsl:attribute name="title">
                          <xsl:value-of select="atom:title"/>
                       </xsl:attribute>
                        <xsl:if test="$posts">
                          <xsl:attribute name="class">active</xsl:attribute>
                        </xsl:if>
                      </xsl:when>
                    </xsl:choose>
                    <xsl:value-of select="planet:name"/>
                  </a>

                  <xsl:if test="$posts[string-length(atom:title) &gt; 0]">
                    <ul>
                      <xsl:for-each select="$posts">
                        <xsl:if test="string-length(atom:title) &gt; 0">
                          <li>
                            <a href="{atom:link[@rel='alternate']/@href}">
                              <xsl:if test="atom:title/@xml:lang != @xml:lang">
                                <xsl:attribute name="xml:lang"
                                  select="{atom:title/@xml:lang}"/>
                              </xsl:if>
                              <xsl:value-of select="atom:title"/>
                            </a>
                          </li>
                        </xsl:if>
                      </xsl:for-each>
                    </ul>
                  </xsl:if>
                </li>
              </xsl:for-each>
            </ul>
          </div>
          <xsl:call-template name="sidebar"/>
        </div>
      </body>
    </html>
  </xsl:template>

  <!-- xhtml content -->
  <xsl:template match='atom:content/xhtml:div | atom:summary/xhtml:div'>
    <xsl:copy>
      <xsl:if test='../@xml:lang and not(../@xml:lang = ../../@xml:lang)'>
        <xsl:attribute name='xml:lang'>
          <xsl:value-of select='../@xml:lang'/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name='class'>content</xsl:attribute>
      <xsl:apply-templates select='@*|node()'/>
    </xsl:copy>
  </xsl:template>

  <!-- plain text content -->
  <xsl:template match='atom:content/text() | atom:summary/text()'>
    <div class='content' xmlns='http://www.w3.org/1999/xhtml'>
      <xsl:if test='../@xml:lang and not(../@xml:lang = ../../@xml:lang)'>
        <xsl:attribute name='xml:lang'>
          <xsl:value-of select='../@xml:lang'/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select='.'/>
    </div>
  </xsl:template>

  <!-- Remove stray atom elements -->
  <xsl:template match='atom:*'>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Feedburner detritus -->
  <xsl:template match="xhtml:div[@class='feedflare']"/>

  <!-- Stripe wordpress size-full class -->
  <xsl:template match="xhtml:img[@class='size-full']"/>

  <!-- Stripe servo.org <i> tags leaking in the main layout -->
  <xsl:template match="xhtml:i[@class='fas fa-link']">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Strip site meter -->
  <xsl:template match="xhtml:div[comment()[. = ' Site Meter ']]"/>

  <!-- pass through everything else -->
  <xsl:template match='@*|node()'>
    <xsl:copy>
      <xsl:apply-templates select='@*|node()'/>
    </xsl:copy>
  </xsl:template>

  <!--
    Planet Venus parser is not happy when it encounters an empty HTML element. As
    a result, the style of an empty element can leak in the subsequent elements.
    To prevent this problem, we add an HTML comment inside the empty elements
    except for self-closing void elements.

    See: https://bugzilla.mozilla.org/show_bug.cgi?id=1673540
  -->
  <xsl:template
    match="*[not(normalize-space())
             and not(contains(
               '|area|base|br|col|embed|hr|img|input|link|meta|param|source|track|wbr|',
               concat('|', local-name(), '|')
             ))]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:comment>empty element</xsl:comment>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
