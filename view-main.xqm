module namespace view = "http://www.iro37.ru/golosovalka/view";

import module namespace data = "http://www.iro37.ru/golosovalka/data" at "data.xqm";

declare variable $view:db-name := $data:dbName;
declare variable $view:radio :=
  <div>
    <div>
        <span>Количество ответов:</span>
          <div class="form-check">
            <label class="form-check-label" for="single">
                <input name="type" type="radio" value="single" id="single" checked="true">Один из списка</input>
            </label>
          </div>
          <div class="form-check">
            <label class="form-check-label" for="multi">
                <input name="type" type="radio" value="multi" id="multi">Несколько из списка</input>
            </label>
          </div>
       </div>
       
       <div>
        <span>Способ подсчета голосов:</span>
          <div class="form-check">
            <label class="form-check-label" for="count1">
                <input name="counting" type="radio" value="simple" id="count1" checked="true">Простое большинство</input>
            </label>
          </div>
          <div class="form-check">
            <label class="form-check-label" for="count2">
                <input name="counting" type="radio" value="qualified" id="count2">Квалифицированное большинство</input>
            </label>
          </div>
       </div>
  </div>;

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
            { $view:radio }
            <button class="btn btn-primary">Создать</button>
        </form>
      </div>
   return
       $temlate update replace node .//toreplace with $content
};

