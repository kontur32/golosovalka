module namespace view = "http://www.iro37.ru/golosovalka/view";

import module namespace data = "http://www.iro37.ru/golosovalka/data" at "data.xqm";

declare 
  %rest:path( "/golosovalka/vote" )
  %rest:GET
  %rest:query-param ( "common", "{$common}" )
  %rest:query-param ( "message", "{$message}" )
  %output:method( "xhtml" )
function view:vote ( $common, $message )
{
  let $data := $data:vote ( $common )
  let $temlate := doc( 'main-tpl.html' )
  let $content := 
          <div class="col">
            <h3>{ $data//meta/title/text() }</h3>
            <p><i>{ $message }</i></p>
            <div class="col">
              { if ( $data:isOpen ( $data ) )
                then ( )
                else (
                  <a href="result?common={ $data/@common }">Результаты голосования</a>
                )
              }
              <p><i>Голосуют { $data/meta/quote/text() } участника</i></p>
              <p><i>Уже проголосовали { count( $data//results/result ) } участника</i></p>
            </div>
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
      $temlate update replace node .//toreplace with $content
};

declare function view:multi ( $data ) {
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
              name="{$i/@id}" 
              value="yes" 
            /> 
               { $i/text() }
            </label>
          </div>
    }
  </label>
};