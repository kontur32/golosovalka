module namespace view = "http://www.iro37.ru/golosovalka/view";

import module namespace request = "http://exquery.org/ns/request";
import module namespace data = "http://www.iro37.ru/golosovalka/data" at "data.xqm";

declare variable $view:db-name := $data:dbName;

declare 
  %rest:path("/golosovalka/result")
  %rest:GET
  %rest:query-param ( "common", "{$common}" )
  %rest:query-param ( "message", "{$message}" )
  %output:method('xhtml')
function view:result ( $common, $message )
{
  let $data := $data:vote ( $common )
  let $voteType := 
      if ( $data/@type = "single")
      then ( "один из" )
      else ( "несколько из" )
      
  let $countingType := 
      if ( $data/@counting = "simple")
      then ( "простое большинство" )
      else ( "квалифицированное большинство" ) 
  
  let $content :=     
      <div class="col">
        <h3>{$data//meta/title/text()}</h3>
        <p><i><b>Тип голосования: </b> { $voteType }</i></p>
        <p><i><b>Способ определения результата: </b> { $countingType }</i></p>
        <p><i><b>Голосовали участников: </b> {count( $data/results/result) }</i></p>
        <table class="table">
          <thead>
            <tr>
              <th>Вопрос</th>
              <th class="text-center">За</th>
              <th class="text-center">Против</th>
              <th class="text-center">Результат</th>
            </tr>
          </thead>
          <tbody>
          {
            for $i in $data//questions/question
            let $qoute := $data/meta/quote/text()
            let $yes := count( $data/results/result/question[ @id = $i/@id and @value="yes" ] )
            let $no := count( $data/results/result/question[ @id = $i/@id and @value="no" ] )
            let $countingQuote := if ( $data/@counting = "simple") then ( 0.5 ) else ( 2 div 3 )
            let $result := if ( ( $yes div $qoute ) > $countingQuote ) then ( "принято" ) else ( "не принято" )
            let $class := if ( $result = "принято" ) then ( "table-success" ) else ( "table-danger" )
            return
              <tr class="{ $class }">
                <td>{$i/text()}</td>
                <td class="text-center">{ $yes }</td>
                <td class="text-center">{ $no }</td>
                <td class="text-center">{ $result }</td>
              </tr>
          }
          </tbody>
        </table>
      <hr/>  
    </div>
  
  return
      $data:mainTemlate update replace node .//toreplace with $content
};