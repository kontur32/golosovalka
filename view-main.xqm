module namespace view = "http://www.iro37.ru/golosovalka/view";
import module namespace request = "http://exquery.org/ns/request";

declare variable $view:db-name := "golosovalka-dev";

declare 
  %rest:path("/golosovalka")
  %rest:GET
  %output:method('xhtml')
function view:main ()
{
  let $temlate := doc( "main-tpl.html" )
  let $content :=
      <div class="col"> 
        <p>Чтобы создать голо-сование, нажмите...</p>
        <form action="/golosovalka/create-vote">
            <button class="btn btn-primary">Создать</button>
        </form>
      </div>
   return
       $temlate update replace node .//toreplace with $content
};