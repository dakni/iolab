<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:ml="http://xmlcalabash.com/ns/extensions/marklogic"
                version="1.0"
                name="delete-collection-entry">
<p:option name='xdb.user'/>
<p:option name='xdb.password'/>
<p:option name='xdb.host'/>
<p:option name='xdb.port'/>
<p:option name='name'/>
<p:output port="result"/>
<p:serialization port="result" indent="true"/>

<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

<ml:adhoc-query>
<p:with-option name='user' select='$xdb.user'/>
<p:with-option name='password' select='$xdb.password'/>
<p:with-option name='host' select='$xdb.host'/>
<p:with-option name='port' select='$xdb.port'/>
<p:with-param name='name' select='$name'/>
<p:input port="source">
<p:inline>
<c:query>
declare namespace http="http://www.xproclet.org/V/HTTP/";
declare namespace app='http://www.w3.org/2007/app';
declare namespace atom='http://www.w3.org/2005/Atom';
declare variable $name external;
 let $uri := concat('app://collections/',$name,'.col'), $d := document($uri)
    return if ($d) then element http:http {
              attribute status { "204" },
              xdmp:document-delete($uri),
              xdmp:collection-delete(concat('app://collections/',$name,'/entry')),
              xdmp:collection-delete(concat('app://collections/',$name,'/media')),
              let $updated := collection('app://collections/')/atom:updated
                 return if ($updated)
                        then xdmp:node-replace($updated,element atom:updated { current-dateTime() })
                        else xdmp:document-insert(
                                 'app://collections/updated.xml',
                                 element atom:updated { current-dateTime() },
                                 xdmp:default-permissions(),
                                 ('app://collections/'))
           }
           else element http:http { attribute status {"404"}, element http:entity { concat("There is no collection named ",$name,".") } }


</c:query>
</p:inline>
</p:input>
</ml:adhoc-query>

</p:declare-step>