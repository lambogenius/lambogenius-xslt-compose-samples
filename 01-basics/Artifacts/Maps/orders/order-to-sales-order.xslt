<?xml version="1.0" encoding="utf-8"?>
<!--
  Order to sales order, in plain XSLT 1.0 (no scripts, no Functions).
  - Imports a shared module (common/normalize.xslt).
  - Takes a parameter ($currency) from the workflow.
  - Adds up line amounts with msxsl:node-set, which XslCompiledTransform provides without scripts.
-->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    exclude-result-prefixes="msxsl">

  <xsl:import href="../common/normalize.xslt"/>

  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>

  <xsl:param name="currency" select="'CAD'"/>

  <xsl:template match="/Order">
    <xsl:variable name="amounts">
      <xsl:for-each select="Lines/Line">
        <amount><xsl:value-of select="Quantity * UnitPrice"/></amount>
      </xsl:for-each>
    </xsl:variable>

    <SalesOrder>
      <OrderNumber>
        <xsl:call-template name="normalize-code">
          <xsl:with-param name="value" select="Number"/>
        </xsl:call-template>
      </OrderNumber>
      <OrderDate><xsl:value-of select="OrderDate"/></OrderDate>
      <CustomerId><xsl:value-of select="CustomerId"/></CustomerId>
      <Currency><xsl:value-of select="$currency"/></Currency>
      <Lines>
        <xsl:for-each select="Lines/Line">
          <Line number="{position()}">
            <Sku>
              <xsl:call-template name="normalize-code">
                <xsl:with-param name="value" select="Sku"/>
              </xsl:call-template>
            </Sku>
            <Quantity><xsl:value-of select="Quantity"/></Quantity>
            <UnitPrice><xsl:value-of select="format-number(UnitPrice, '0.00')"/></UnitPrice>
            <Amount>
              <xsl:call-template name="money">
                <xsl:with-param name="amount" select="Quantity * UnitPrice"/>
              </xsl:call-template>
            </Amount>
          </Line>
        </xsl:for-each>
      </Lines>
      <Total units="{sum(Lines/Line/Quantity)}">
        <xsl:call-template name="money">
          <xsl:with-param name="amount" select="sum(msxsl:node-set($amounts)/amount)"/>
        </xsl:call-template>
      </Total>
    </SalesOrder>
  </xsl:template>
</xsl:stylesheet>
