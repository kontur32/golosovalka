module namespace data = "http://www.iro37.ru/golosovalka/data";

declare variable $data:dbName := "golosovalka-dev";

declare variable $data:vote := function ( $token ) {
  db:open( $data:dbName , "data" )/data/vote[ @common= $token or @master = $token ]
};

declare variable $data:isOpen := function ( $data ) {
  count( $data/results/result ) < $data/meta/quote/data()
};

declare variable $data:mainTemlate := doc( "src/main-tpl.html" );

