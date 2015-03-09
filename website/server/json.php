<?php

parking_lots_dd::get_parking_lots();

if( $_GET['view']=='array') var_dump(parking_lots_dd::$tables);
else echo json_encode(parking_lots_dd::$tables);

/*
	static class for scraping "http://www.dresden.de/freie-parkplaetze"
*/
class parking_lots_dd
{
	private static $source_address = 'http://www.dresden.de/freie-parkplaetze';
	#private static $source_address = 'dd.html';
	private static $site_content 	= array();
	
	public static $tables			= array();
	public static $lot_names		= array();
	public static $errors 			= array();
	
	public static function get_parking_lots()
	{
		static::$site_content = static::get_webcontent();
		$tables = static::extract_parking_lot_tables( static::$site_content );
		foreach( $tables AS $table) static::$tables[] = static::extract_html2raw( $table );
	}
	
			
	
	/*
		every parking space, is a single table, this func put every table into an array child
	 */
	private static function getStatusByImage($html){
		$imgtostatus = array(
			'/img/parken/p_gruen.gif' => 'many',
			'/img/parken/p_gelb.gif' => 'few',
			'/img/parken/p_rot.gif' => 'full',
			'/img/parken/p_geschlossen.gif' => 'closed',
			'/img/parken/p_blau.gif' => 'nodata',
		);
		$doc = new DOMDocument();
		$doc->loadHTML($html);
		$tags = $doc->getElementsByTagName('img');
		$state;
		foreach($tags as $tag){
			$state  = $imgtostatus[$tag->getAttribute('src')];
		}
		return $state;
	}

	private static function extract_html2raw( $html )
	{	
		include("geo.php");
		$table = array();
		$ix = count($html);
		while($i <= $ix)
		{ 	
			//get the name of the parking spaces
			if( substr_count( $html[$i],'<thead>') > 0 )
			{
				$i++; //go into the <tr>
				$i++; //go into the <th>
				$table['name'] = trim( strip_tags( $html[$i] ) );					
			}	
			//get the names of the parking lots
			if( substr_count( $html[$i],'<a href=') > 0 )
			{
				$state = parking_lots_dd::getStatusByImage($html[$i]);
				$name = self::german_letters( self::extract_from_html_link( $html[$i] ));
				
				$i++;
				$i++;
				$count = trim( strip_tags( $html[$i] ) );
				$i++;
				$i++;
				$free = trim( strip_tags( $html[$i] ) );
				$llat = $lat[$name];
				$llon = $lon[$name];				
				$table['lots'][] = array( 'name'=>$name, 'count'=>$count, 'free'=>$free, 'state'=>$state, 'lat'=>$llat, 'lon'=>$llon );
			}
			
			
			
			$i++;
		}
		
		return $table;
	}
	
	
	
	/*
		cuts just the part of the array where the parking lots are stored,
		this is in the tables named "zahlen nodeco".
		Also, the function saves the hole table
	*/
	private static function extract_parking_lot_tables( $html )
	{
		if(count($html) <= 0 ) {
			static::$errors[] = 'error 1, no parking lots can be found';
			return false;
			}
		$tables = array(); //array of the single parking spaces
		$larr = array(); //lines array
		$cat = false;
		
		foreach( $html AS $line )
		{
			if( substr_count($line, '<table class="zahlen nodeco"' ) === 1 ) {
				$cat = true;			
				if( count( $larr ) > 0 ) //if some further collected table lines are saved, put them into the tables array
				{
					$tables[] = $larr;
					unset($larr);
					$larr = array();
				}
			}
			if( $cat === true && substr_count($line, '</table') === 1) 			$cat = false;
			if($cat === true) $larr[] = $line;
			
			// if( $cat === true && substr_count($line, '<a href="/freie-parkplaetze/parken/detail?' ) === 1 ) 
			// {
				// static::$lot_names[] = self::extract_from_html_link($line);				
			// }
			
		}		
		//add last table
		$tables[] = $larr;
		
		return $tables;
	}
	
	
	
	/*
		its crazy, not all german letters are right printed with utf8_encode(), 
		so here we do some replacements 		
	*/
	private static function german_letters( $str )
	{
		#$str = utf8_decode($str);
		#$web = array('ÃŸ','Ã¼');
		#$ger = array('ß','ü');
		
		#seems to be no need at this time
		return str_replace($web, $ger, $str);
	}
	
	
	
	
	/*
		scrapes just the human viewable part of an a_href
	*/
	private static function extract_from_html_link( $html )
	{
		$link_pos = strpos($html, '<a href=');
		$start = strpos($html, '>', $link_pos) + 1;
		$len = strpos($html, '<', $start) - $start;
		return trim( substr($html, $start , $len));
	}
	
	
	/*
		download all the page content in an private array
	*/
	private static function get_webcontent()
	{
		return file(static::$source_address);
	}		
}
?>
