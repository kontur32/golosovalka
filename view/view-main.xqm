module namespace view = "http://www.iro37.ru/golosovalka/view";

import module namespace data = "http://www.iro37.ru/golosovalka/data" at "../data.xqm";

declare variable $view:db-name := $data:dbName;

declare variable $view:radio := doc("../src/radio-tpl.html");

declare 
  %rest:path("/golosovalka")
  %rest:GET
  %output:method('xhtml')
function view:main ()
{
  let $content :=
      <div class="col"> 
        <p>Чтобы создать голосование, нажмите...</p>
        <form action="/golosovalka/create-vote">
          <button class="btn btn-primary">Создать</button>
            <div>
              { $view:radio }
            </div>
        </form>      
      </div>
      
   return
       $data:mainTemlate update replace node .//toreplace with $content
};