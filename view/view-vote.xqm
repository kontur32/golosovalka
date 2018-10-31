module namespace view = "http://www.iro37.ru/golosovalka/view";

import module namespace data = "http://www.iro37.ru/golosovalka/data" at "../data.xqm";

declare 
  %rest:path( "/golosovalka/vote" )
  %rest:GET
  %rest:query-param ( "common", "{$common}" )
  %rest:query-param ( "message", "{$message}" )
  %output:method( "xhtml" )
function view:vote ( $common, $message )
{
  let $data := $data:vote ( $common )
  let $content := 
          <div >
            <h3>{ $data//meta/title/text() }</h3>
            <p><i>{ $message }</i></p>
              { if ( $data:isOpen ( $data ) )
                then ( )
                else (
                  <a href="result?common={ $data/@common }">Результаты голосования</a>
                )
              }
              <p><i>Голосуют { $data/meta/quote/text() } участника</i></p>
              <p><i>Уже проголосовали { count( $data//results/result ) } участника</i></p>
            <hr/>
            {
              if 
                ( $data:isOpen ( $data ) )
              then
              (
              <form action="update-result" method="get">
                  <div class="form-group">
                    { if ( $data/@type = "single" )
                      then (
                        view:single ( $data )
                      )
                      else (
                        view:multi ( $data )
                      ) 
                    }
                  </div>
                  <input type="text" name="common" value="{$data/@common}" hidden=""/>               
                  <div class="form-group">
                      <button type="submit" class="btn btn-primary">Голосовать</button>
                  </div>
              </form>
            )
            else 
              (
                <p>Голосование закрыто</p>
              )
        }
          </div>
  return
      $data:mainTemlate update replace node .//toreplace with $content
};

declare function view:multi ( $data ) {
  let $isNeutral := if ( $data/@var = "neutral" ) then ( true() ) else ( false () )
  for $i in $data//questions/question
  return 
  <label for="q1" class="form-check">
      {$i/text()}
      <div class="form-check">
          <label class="form-check-label">
              <input 
              type="radio" 
              class="form-check-input" 
              name="{$i/@id}" 
              value="yes" 
              checked=""/> 
              За
          </label>
      </div>
      <div class="form-check">
          <label class="form-check-label">
              <input 
              type="radio" 
              class="form-check-input" 
              name="{$i/@id}" 
              value="no"/>
              Против
          </label>
      </div>
      {
      if ( $isNeutral )
      then (
        <div class="form-check">
          <label class="form-check-label">
              <input 
              type="radio" 
              class="form-check-input" 
              name="{$i/@id}" 
              value="neutral"/>
              Воздержался
          </label>
      </div>
      )
      else ()
      }
      <hr/>
  </label>
};

declare function view:single ( $data ) {
  <label class="form-check">
  {
    
    for $i in $data//questions/question
    return  
        <div class="form-check">
            <label class="form-check-label">
              <input 
              type="radio" 
              class="form-check-input" 
              name="q0" 
              value="{$i/@id}" 
            /> 
               { $i/text() }
            </label>
          </div>
    }
    {
      let $isNeutral := if ( $data/@var = "neutral" ) then ( true() ) else ( false () )  
      return
      if ( $isNeutral )
      then (
        <div class="form-check">
          <label class="form-check-label">
              <input 
              type="radio" 
              class="form-check-input" 
              name="q0" 
              value="neutral"/>
              Воздержался
          </label>
      </div>
      )
      else ()
      }
  </label>
};