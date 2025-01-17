<?php

/**
 * This file contains the files necessary to display news as an XML feed.
 *
 * @name      ElkArte Forum
 * @copyright ElkArte Forum contributors
 * @license   BSD http://opensource.org/licenses/BSD-3-Clause
 *
 * This software is a derived product, based on:
 *
 * Simple Machines Forum (SMF)
 * copyright:	2011 Simple Machines (http://www.simplemachines.org)
 * license:		BSD, See included LICENSE.TXT for terms and conditions.
 *
 * @version 1.0 Release Candidate 2
 *
 *
 */

if (!defined('ELK'))
	die('No access...');

/**
 * News Controller
 */
class News_Controller extends Action_Controller
{
	/**
	 * Holds news specific version board query for news feeds
	 * @var string
	 */
	private $_query_this_board = null;

	/**
	 * Holds the limit for the number of items to get
	 * @var int
	 */
	private $_limit;

	/**
	 * Dispatcher. Forwards to the action to execute.
	 *
	 * @see Action_Controller::action_index()
	 */
	public function action_index()
	{
		// do... something, of your favorite.
		// $this->action_xmlnews();
	}

	/**
	 * Outputs xml data representing recent information or a profile.
	 *
	 * What it does:
	 * - Can be passed 4 subactions which decide what is output:
	 *   'recent' for recent posts,
	 *   'news' for news topics,
	 *   'members' for recently registered members,
	 *   'profile' for a member's profile.
	 * - To display a member's profile, a user id has to be given. (;u=1) e.g. ?action=.xml;sa=profile;u=1;type=atom
	 * - Outputs an rss feed instead of a proprietary one if the 'type' $_GET
	 * parameter is 'rss' or 'rss2'.
	 * - Accessed via ?action=.xml
	 * - Does not use any templates, sub templates, or template layers.
	 *
	 * @uses Stats language file.
	 */
	public function action_showfeed()
	{
		global $board, $board_info, $context, $scripturl, $boardurl, $txt, $modSettings, $user_info;
		global $forum_version, $cdata_override, $settings;

		// If it's not enabled, die.
		if (empty($modSettings['xmlnews_enable']))
			obExit(false);

		loadLanguage('Stats');
		$txt['xml_rss_desc'] = replaceBasicActionUrl($txt['xml_rss_desc']);

		// Default to latest 5.  No more than whats defined in the ACP or 255
		$limit = empty($modSettings['xmlnews_limit']) ? 5 : min($modSettings['xmlnews_limit'], 255);
		$this->_limit = empty($_GET['limit']) || (int) $_GET['limit'] < 1 ? $limit : min((int) $_GET['limit'], $limit);

		// Handle the cases where a board, boards, or category is asked for.
		$this->_query_this_board = '1=1';
		$context['optimize_msg'] = array(
			'highest' => 'm.id_msg <= b.id_last_msg',
		);

		if (!empty($_REQUEST['c']) && empty($board))
		{
			$categories = array_map('intval', explode(',', $_REQUEST['c']));

			if (count($categories) == 1)
			{
				require_once(SUBSDIR . '/Categories.subs.php');
				$feed_title = categoryName($categories[0]);

				$feed_title = ' - ' . strip_tags($feed_title);
			}

			$boards_posts = boardsPosts(array(), $categories);
			$total_cat_posts = array_sum($boards_posts);
			$boards = array_keys($boards_posts);

			if (!empty($boards))
				$this->_query_this_board = 'b.id_board IN (' . implode(', ', $boards) . ')';

			// Try to limit the number of messages we look through.
			if ($total_cat_posts > 100 && $total_cat_posts > $modSettings['totalMessages'] / 15)
				$context['optimize_msg']['lowest'] = 'm.id_msg >= ' . max(0, $modSettings['maxMsgID'] - 400 - $this->_limit * 5);
		}
		elseif (!empty($_REQUEST['boards']))
		{
			require_once(SUBSDIR . '/Boards.subs.php');
			$query_boards = array_map('intval', explode(',', $_REQUEST['boards']));

			$boards_data = fetchBoardsInfo(array('boards' => $query_boards), array('selects' => 'detailed'));

			// Either the board specified doesn't exist or you have no access.
			$num_boards = count($boards_data);
			if ($num_boards == 0)
				fatal_lang_error('no_board');

			$total_posts = 0;
			$boards = array_keys($boards_data);
			foreach ($boards_data as $row)
			{
				if ($num_boards == 1)
					$feed_title = ' - ' . strip_tags($row['name']);

				$total_posts += $row['num_posts'];
			}

			$this->_query_this_board = 'b.id_board IN (' . implode(', ', $boards) . ')';

			// The more boards, the more we're going to look through...
			if ($total_posts > 100 && $total_posts > $modSettings['totalMessages'] / 12)
				$context['optimize_msg']['lowest'] = 'm.id_msg >= ' . max(0, $modSettings['maxMsgID'] - 500 - $this->_limit * 5);
		}
		elseif (!empty($board))
		{
			require_once(SUBSDIR . '/Boards.subs.php');
			$boards_data = fetchBoardsInfo(array('boards' => $board), array('selects' => 'posts'));

			$feed_title = ' - ' . strip_tags($board_info['name']);

			$this->_query_this_board = 'b.id_board = ' . $board;

			// Try to look through just a few messages, if at all possible.
			if ($boards_data[$board]['num_posts'] > 80 && $boards_data[$board]['num_posts'] > $modSettings['totalMessages'] / 10)
				$context['optimize_msg']['lowest'] = 'm.id_msg >= ' . max(0, $modSettings['maxMsgID'] - 600 - $this->_limit * 5);
		}
		else
		{
			$this->_query_this_board = '{query_see_board}' . (!empty($modSettings['recycle_enable']) && $modSettings['recycle_board'] > 0 ? '
				AND b.id_board != ' . $modSettings['recycle_board'] : '');
			$context['optimize_msg']['lowest'] = 'm.id_msg >= ' . max(0, $modSettings['maxMsgID'] - 100 - $this->_limit * 5);
		}

		// If format isn't set, rss2 is default
		$xml_format = isset($_GET['type']) && in_array($_GET['type'], array('rss', 'rss2', 'atom', 'rdf', 'webslice')) ? $_GET['type'] : 'rss2';

		// List all the different types of data they can pull.
		$subActions = array(
			'recent' => array('action_xmlrecent'),
			'news' => array('action_xmlnews'),
			'members' => array('action_xmlmembers'),
			'profile' => array('action_xmlprofile'),
		);

		// Easy adding of sub actions
		call_integration_hook('integrate_xmlfeeds', array(&$subActions));

		$subAction = isset($_GET['sa']) && isset($subActions[$_GET['sa']]) ? $_GET['sa'] : 'recent';

		// Webslices doesn't do everything (yet? ever?) so for now only recent posts is allowed in that format
		if ($xml_format == 'webslice' && $subAction != 'recent')
			$xml_format = 'rss2';
		// If this is webslices we kinda cheat - we allow a template that we call direct for the HTML, and we override the CDATA.
		elseif ($xml_format == 'webslice')
		{
			$context['user'] += $user_info;
			$cdata_override = true;
			loadTemplate('Xml');
		}

		// We only want some information, not all of it.
		$cachekey = array($xml_format, $_GET['action'], $this->_limit, $subAction);
		foreach (array('board', 'boards', 'c') as $var)
		{
			if (isset($_REQUEST[$var]))
				$cachekey[] = $_REQUEST[$var];
		}

		$cachekey = md5(serialize($cachekey) . (!empty($this->_query_this_board) ? $this->_query_this_board : ''));
		$cache_t = microtime(true);

		// Get the associative array representing the xml.
		if (!empty($modSettings['cache_enable']) && (!$user_info['is_guest'] || $modSettings['cache_enable'] >= 3))
			$xml = cache_get_data('xmlfeed-' . $xml_format . ':' . ($user_info['is_guest'] ? '' : $user_info['id'] . '-') . $cachekey, 240);

		if (empty($xml))
		{
			$xml = $this->{$subActions[$subAction][0]}($xml_format);

			if (!empty($modSettings['cache_enable']) && (($user_info['is_guest'] && $modSettings['cache_enable'] >= 3)
			|| (!$user_info['is_guest'] && (microtime(true) - $cache_t > 0.2))))
				cache_put_data('xmlfeed-' . $xml_format . ':' . ($user_info['is_guest'] ? '' : $user_info['id'] . '-') . $cachekey, $xml, 240);
		}

		$feed_title = htmlspecialchars(strip_tags($context['forum_name']), ENT_COMPAT, 'UTF-8') . (isset($feed_title) ? $feed_title : '');

		// This is an xml file....
		@ob_end_clean();
		if (!empty($modSettings['enableCompressedOutput']))
			ob_start('ob_gzhandler');
		else
			ob_start();

		if (isset($_REQUEST['debug']))
			header('Content-Type: text/xml; charset=UTF-8');
		elseif ($xml_format == 'rss' || $xml_format == 'rss2' || $xml_format == 'webslice')
			header('Content-Type: application/rss+xml; charset=UTF-8');
		elseif ($xml_format == 'atom')
			header('Content-Type: application/atom+xml; charset=UTF-8');
		elseif ($xml_format == 'rdf')
			header('Content-Type: ' . (isBrowser('ie') ? 'text/xml' : 'application/rdf+xml') . '; charset=UTF-8');

		// First, output the xml header.
		echo '<?xml version="1.0" encoding="UTF-8"?' . '>';

		// Are we outputting an rss feed or one with more information?
		if ($xml_format == 'rss' || $xml_format == 'rss2')
		{
			// Start with an RSS 2.0 header.
			echo '
	<rss version=', $xml_format == 'rss2' ? '"2.0" xmlns:dc="http://purl.org/dc/elements/1.1/"' : '"0.92"', ' xml:lang="', strtr($txt['lang_locale'], '_', '-'), '">
		<channel>
			<title>', $feed_title, '</title>
			<link>', $scripturl, '</link>
			<description><![CDATA[', strip_tags($txt['xml_rss_desc']), ']]></description>
			<generator>ElkArte</generator>
			<ttl>30</ttl>
			<image>
				<url>', $settings['default_theme_url'], '/images/logo.png</url>
				<title>', $feed_title, '</title>
				<link>', $scripturl, '</link>
			</image>';

			// Output all of the associative array, start indenting with 2 tabs, and name everything "item".
			dumpTags($xml, 2, 'item', $xml_format);

			// Output the footer of the xml.
			echo '
		</channel>
	</rss>';
		}
		elseif ($xml_format == 'webslice')
		{
			// Format specification http://msdn.microsoft.com/en-us/library/cc304073%28VS.85%29.aspx
			// Known browsers to support webslices: IE8, IE9, Firefox with Webchunks addon.
			// It uses RSS 2.

			// We send a feed with recent posts, and alerts for PMs for logged in users
			$context['recent_posts_data'] = $xml;
			$context['can_pm_read'] = allowedTo('pm_read');

			// This always has RSS 2
			echo '
	<rss version="2.0" xmlns:mon="http://www.microsoft.com/schemas/rss/monitoring/2007" xml:lang="', strtr($txt['lang_locale'], '_', '-'), '">
		<channel>
			<title>', $feed_title, ' - ', $txt['recent_posts'], '</title>
			<link>', $scripturl, '?action=recent</link>
			<description><![CDATA[', strip_tags($txt['xml_rss_desc']), ']]></description>
			<item>
				<title>', $feed_title, ' - ', $txt['recent_posts'], '</title>
				<link>', $scripturl, '?action=recent</link>
				<description><![CDATA[
					', template_webslice_header_above(), '
					', template_webslice_recent_posts(), '
				]]></description>
			</item>
		</channel>
	</rss>';
		}
		elseif ($xml_format == 'atom')
		{
			$url_parts = array();
			foreach (array('board', 'boards', 'c') as $var)
				if (isset($_REQUEST[$var]))
					$url_parts[] = $var . '=' . (is_array($_REQUEST[$var]) ? implode(',', $_REQUEST[$var]) : $_REQUEST[$var]);

			echo '
	<feed xmlns="http://www.w3.org/2005/Atom">
		<title>', $feed_title, '</title>
		<link rel="alternate" type="text/html" href="', $scripturl, '" />
		<link rel="self" type="application/rss+xml" href="', $scripturl, '?type=atom;action=.xml', !empty($url_parts) ? ';' . implode(';', $url_parts) : '', '" />
		<id>', $scripturl, '</id>
		<icon>', $boardurl, '/favicon.ico</icon>

		<updated>', gmstrftime('%Y-%m-%dT%H:%M:%SZ'), '</updated>
		<subtitle><![CDATA[', strip_tags($txt['xml_rss_desc']), ']]></subtitle>
		<generator uri="http://www.elkarte.net" version="', strtr($forum_version, array('ElkArte' => '')), '">ElkArte</generator>
		<author>
			<name>', strip_tags($context['forum_name']), '</name>
		</author>';

			dumpTags($xml, 2, 'entry', $xml_format);

			echo '
	</feed>';
		}
		// rdf by default
		else
		{
			echo '
	<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://purl.org/rss/1.0/">
		<channel rdf:about="', $scripturl, '">
			<title>', $feed_title, '</title>
			<link>', $scripturl, '</link>
			<description><![CDATA[', strip_tags($txt['xml_rss_desc']), ']]></description>
			<items>
				<rdf:Seq>';

			foreach ($xml as $item)
				echo '
					<rdf:li rdf:resource="', $item['link'], '" />';

			echo '
				</rdf:Seq>
			</items>
		</channel>
	';

			dumpTags($xml, 1, 'item', $xml_format);

			echo '
	</rdf:RDF>';
		}

		obExit(false);
	}

	/**
	 * Retrieve the list of members from database.
	 * The array will be generated to match the format.
	 *
	 * @param string $xml_format
	 * @return mixed[]
	 */
	public function action_xmlmembers($xml_format)
	{
		global $scripturl;

		if (!allowedTo('view_mlist'))
			return array();

		// Find the most recent members.
		require_once(SUBSDIR . '/Members.subs.php');
		$members = recentMembers((int) $this->_limit);

		// No data yet
		$data = array();

		foreach ($members as $member)
		{
			// Make the data look rss-ish.
			if ($xml_format == 'rss' || $xml_format == 'rss2')
				$data[] = array(
					'title' => cdata_parse($member['real_name']),
					'link' => $scripturl . '?action=profile;u=' . $member['id_member'],
					'comments' => $scripturl . '?action=pm;sa=send;u=' . $member['id_member'],
					'pubDate' => gmdate('D, d M Y H:i:s \G\M\T', $member['date_registered']),
					'guid' => $scripturl . '?action=profile;u=' . $member['id_member'],
				);
			elseif ($xml_format == 'rdf')
				$data[] = array(
					'title' => cdata_parse($member['real_name']),
					'link' => $scripturl . '?action=profile;u=' . $member['id_member'],
				);
			elseif ($xml_format == 'atom')
				$data[] = array(
					'title' => cdata_parse($member['real_name']),
					'link' => $scripturl . '?action=profile;u=' . $member['id_member'],
					'published' => gmstrftime('%Y-%m-%dT%H:%M:%SZ', $member['date_registered']),
					'updated' => gmstrftime('%Y-%m-%dT%H:%M:%SZ', $member['last_login']),
					'id' => $scripturl . '?action=profile;u=' . $member['id_member'],
				);
			// More logical format for the data, but harder to apply.
			else
				$data[] = array(
					'name' => cdata_parse($member['real_name']),
					'time' => htmlspecialchars(strip_tags(standardTime($member['date_registered'])), ENT_COMPAT, 'UTF-8'),
					'id' => $member['id_member'],
					'link' => $scripturl . '?action=profile;u=' . $member['id_member']
				);
		}

		return $data;
	}

	/**
	 * Get the latest topics information from a specific board, to display later.
	 * The returned array will be generated to match the xmf_format.
	 *
	 * @param string $xml_format one of rss, rss2, rdf, atom
	 * @return mixed[] array of topics
	 */
	public function action_xmlnews($xml_format)
	{
		global $scripturl, $modSettings, $board;

		// Get the latest topics from a board
		require_once(SUBSDIR . '/News.subs.php');
		$results = getXMLNews($this->_query_this_board, $board, $this->_limit);

		// Prepare it for the feed in the format chosen (rss, atom, etc)
		$data = array();
		foreach ($results as $row)
		{
			// Limit the length of the message, if the option is set.
			if (!empty($modSettings['xmlnews_maxlen']) && Util::strlen(str_replace('<br />', "\n", $row['body'])) > $modSettings['xmlnews_maxlen'])
				$row['body'] = strtr(Util::shorten_text(str_replace('<br />', "\n", $row['body']), $modSettings['xmlnews_maxlen'], true), array("\n" => '<br />'));

			$row['body'] = parse_bbc($row['body'], $row['smileys_enabled'], $row['id_msg']);

			// Dirty mouth?
			censorText($row['body']);
			censorText($row['subject']);

			// Being news, this actually makes sense in rss format.
			if ($xml_format == 'rss' || $xml_format == 'rss2')
			{
				$data[] = array(
					'title' => cdata_parse($row['subject']),
					'link' => $scripturl . '?topic=' . $row['id_topic'] . '.0',
					'description' => cdata_parse($row['body']),
					'author' => in_array(showEmailAddress(!empty($row['hide_email']), $row['id_member']), array('yes', 'yes_permission_override')) ? $row['poster_email'] . ' (' . $row['poster_name'] . ')' : $row['poster_name'],
					'comments' => $scripturl . '?action=post;topic=' . $row['id_topic'] . '.0',
					'category' => '<![CDATA[' . $row['bname'] . ']]>',
					'pubDate' => gmdate('D, d M Y H:i:s \G\M\T', $row['poster_time']),
					'guid' => $scripturl . '?topic=' . $row['id_topic'] . '.0',
				);

				// Add the poster name on if we are rss2
				if ($xml_format == 'rss2')
					$data[count($data) - 1]['dc:creator'] = $row['poster_name'];
			}
			// RDF Format anyone
			elseif ($xml_format == 'rdf')
			{
				$data[] = array(
					'title' => cdata_parse($row['subject']),
					'link' => $scripturl . '?topic=' . $row['id_topic'] . '.0',
					'description' => cdata_parse($row['body']),
				);
			}
			// Atom feed
			elseif ($xml_format == 'atom')
			{
				$data[] = array(
					'title' => cdata_parse($row['subject']),
					'link' => $scripturl . '?topic=' . $row['id_topic'] . '.0',
					'summary' => cdata_parse($row['body']),
					'category' => $row['bname'],
					'author' => array(
						'name' => $row['poster_name'],
						'email' => in_array(showEmailAddress(!empty($row['hide_email']), $row['id_member']), array('yes', 'yes_permission_override')) ? $row['poster_email'] : null,
						'uri' => !empty($row['id_member']) ? $scripturl . '?action=profile;u=' . $row['id_member'] : '',
					),
					'published' => gmstrftime('%Y-%m-%dT%H:%M:%SZ', $row['poster_time']),
					'modified' => gmstrftime('%Y-%m-%dT%H:%M:%SZ', empty($row['modified_time']) ? $row['poster_time'] : $row['modified_time']),
					'id' => $scripturl . '?topic=' . $row['id_topic'] . '.0',
				);
			}
			// The biggest difference here is more information.
			else
			{
				$data[] = array(
				'time' => htmlspecialchars(strip_tags(standardTime($row['poster_time'])), ENT_COMPAT, 'UTF-8'),
					'id' => $row['id_topic'],
					'subject' => cdata_parse($row['subject']),
					'body' => cdata_parse($row['body']),
					'poster' => array(
						'name' => cdata_parse($row['poster_name']),
						'id' => $row['id_member'],
						'link' => !empty($row['id_member']) ? $scripturl . '?action=profile;u=' . $row['id_member'] : '',
					),
					'topic' => $row['id_topic'],
					'board' => array(
						'name' => cdata_parse($row['bname']),
						'id' => $row['id_board'],
						'link' => $scripturl . '?board=' . $row['id_board'] . '.0',
					),
					'link' => $scripturl . '?topic=' . $row['id_topic'] . '.0',
				);
			}
		}

		return $data;
	}

	/**
	 * Get the recent topics to display.
	 * The returned array will be generated to match the xml_format.
	 *
	 * @param string $xml_format one of rss, rss2, rdf, atom
	 * @return mixed[] of recent posts
	 */
	public function action_xmlrecent($xml_format)
	{
		global $scripturl, $modSettings, $board;

		// Get the latest news
		require_once(SUBSDIR . '/News.subs.php');
		$results = getXMLRecent($this->_query_this_board, $board, $this->_limit);

		// Loop on the results and prepare them in the format requested
		$data = array();
		foreach ($results as $row)
		{
			// Limit the length of the message, if the option is set.
			if (!empty($modSettings['xmlnews_maxlen']) && Util::strlen(str_replace('<br />', "\n", $row['body'])) > $modSettings['xmlnews_maxlen'])
				$row['body'] = strtr(Util::shorten_text(str_replace('<br />', "\n", $row['body']), $modSettings['xmlnews_maxlen'], true), array("\n" => '<br />'));

			$row['body'] = parse_bbc($row['body'], $row['smileys_enabled'], $row['id_msg']);

			// You can't say that
			censorText($row['body']);
			censorText($row['subject']);

			// Doesn't work as well as news, but it kinda does..
			if ($xml_format == 'rss' || $xml_format == 'rss2')
			{
				$data[] = array(
					'title' => $row['subject'],
					'link' => $scripturl . '?topic=' . $row['id_topic'] . '.msg' . $row['id_msg'] . '#msg' . $row['id_msg'],
					'description' => cdata_parse($row['body']),
					'author' => in_array(showEmailAddress(!empty($row['hide_email']), $row['id_member']), array('yes', 'yes_permission_override')) ? $row['poster_email'] : $row['poster_name'],
					'category' => cdata_parse($row['bname']),
					'comments' => $scripturl . '?action=post;topic=' . $row['id_topic'] . '.0',
					'pubDate' => gmdate('D, d M Y H:i:s \G\M\T', $row['poster_time']),
					'guid' => $scripturl . '?topic=' . $row['id_topic'] . '.msg' . $row['id_msg'] . '#msg' . $row['id_msg']
				);

				// Add the poster name on if we are rss2
				if ($xml_format == 'rss2')
					$data[count($data) - 1]['dc:creator'] = $row['poster_name'];
			}
			elseif ($xml_format == 'rdf')
			{
				$data[] = array(
					'title' => $row['subject'],
					'link' => $scripturl . '?topic=' . $row['id_topic'] . '.msg' . $row['id_msg'] . '#msg' . $row['id_msg'],
					'description' => cdata_parse($row['body']),
				);
			}
			elseif ($xml_format == 'atom')
			{
				$data[] = array(
					'title' => $row['subject'],
					'link' => $scripturl . '?topic=' . $row['id_topic'] . '.msg' . $row['id_msg'] . '#msg' . $row['id_msg'],
					'summary' => cdata_parse($row['body']),
					'category' => $row['bname'],
					'author' => array(
						'name' => $row['poster_name'],
						'email' => in_array(showEmailAddress(!empty($row['hide_email']), $row['id_member']), array('yes', 'yes_permission_override')) ? $row['poster_email'] : null,
						'uri' => !empty($row['id_member']) ? $scripturl . '?action=profile;u=' . $row['id_member'] : ''
					),
					'published' => gmstrftime('%Y-%m-%dT%H:%M:%SZ', $row['poster_time']),
					'updated' => gmstrftime('%Y-%m-%dT%H:%M:%SZ', empty($row['modified_time']) ? $row['poster_time'] : $row['modified_time']),
					'id' => $scripturl . '?topic=' . $row['id_topic'] . '.msg' . $row['id_msg'] . '#msg' . $row['id_msg'],
				);
			}
			// A lot of information here.  Should be enough to please the rss-ers.
			else
			{
				$data[] = array(
				'time' => htmlspecialchars(strip_tags(standardTime($row['poster_time'])), ENT_COMPAT, 'UTF-8'),
					'id' => $row['id_msg'],
					'subject' => cdata_parse($row['subject']),
					'body' => cdata_parse($row['body']),
					'starter' => array(
						'name' => cdata_parse($row['first_poster_name']),
						'id' => $row['id_first_member'],
						'link' => !empty($row['id_first_member']) ? $scripturl . '?action=profile;u=' . $row['id_first_member'] : ''
					),
					'poster' => array(
						'name' => cdata_parse($row['poster_name']),
						'id' => $row['id_member'],
						'link' => !empty($row['id_member']) ? $scripturl . '?action=profile;u=' . $row['id_member'] : ''
					),
					'topic' => array(
						'subject' => cdata_parse($row['first_subject']),
						'id' => $row['id_topic'],
						'link' => $scripturl . '?topic=' . $row['id_topic'] . '.new#new'
					),
					'board' => array(
						'name' => cdata_parse($row['bname']),
						'id' => $row['id_board'],
						'link' => $scripturl . '?board=' . $row['id_board'] . '.0'
					),
					'link' => $scripturl . '?topic=' . $row['id_topic'] . '.msg' . $row['id_msg'] . '#msg' . $row['id_msg']
				);
			}
		}

		return $data;
	}

	/**
	 * Get the profile information for member into an array,
	 * which will be generated to match the xml_format.
	 *
	 * @param string $xml_format one of rss, rss2, rdf, atom
	 * @return mixed[] array of profile data.
	 */
	public function action_xmlprofile($xml_format)
	{
		global $scripturl, $memberContext, $user_profile, $modSettings, $user_info;

		// You must input a valid user....
		if (empty($_GET['u']) || loadMemberData((int) $_GET['u']) === false)
			return array();

		// Make sure the id is a number and not "I like trying to hack the database".
		$uid = (int) $_GET['u'];

		// Load the member's contextual information!
		if (!loadMemberContext($uid) || !allowedTo('profile_view_any'))
			return array();

		$profile = &$memberContext[$uid];

		// No feed data yet
		$data = array();

		if ($xml_format == 'rss' || $xml_format == 'rss2')
			$data = array(array(
				'title' => cdata_parse($profile['name']),
				'link' => $scripturl . '?action=profile;u=' . $profile['id'],
				'description' => cdata_parse(isset($profile['group']) ? $profile['group'] : $profile['post_group']),
				'comments' => $scripturl . '?action=pm;sa=send;u=' . $profile['id'],
				'pubDate' => gmdate('D, d M Y H:i:s \G\M\T', $user_profile[$profile['id']]['date_registered']),
				'guid' => $scripturl . '?action=profile;u=' . $profile['id'],
			));
		elseif ($xml_format == 'rdf')
			$data = array(array(
				'title' => cdata_parse($profile['name']),
				'link' => $scripturl . '?action=profile;u=' . $profile['id'],
				'description' => cdata_parse(isset($profile['group']) ? $profile['group'] : $profile['post_group']),
			));
		elseif ($xml_format == 'atom')
			$data[] = array(
				'title' => cdata_parse($profile['name']),
				'link' => $scripturl . '?action=profile;u=' . $profile['id'],
				'summary' => cdata_parse(isset($profile['group']) ? $profile['group'] : $profile['post_group']),
				'author' => array(
					'name' => $profile['real_name'],
					'email' => in_array(showEmailAddress(!empty($profile['hide_email']), $profile['id']), array('yes', 'yes_permission_override')) ? $profile['email'] : null,
					'uri' => !empty($profile['website']) ? $profile['website']['url'] : ''
				),
				'published' => gmstrftime('%Y-%m-%dT%H:%M:%SZ', $user_profile[$profile['id']]['date_registered']),
				'updated' => gmstrftime('%Y-%m-%dT%H:%M:%SZ', $user_profile[$profile['id']]['last_login']),
				'id' => $scripturl . '?action=profile;u=' . $profile['id'],
				'logo' => !empty($profile['avatar']) ? $profile['avatar']['url'] : '',
			);
		else
		{
			$data = array(
				'username' => $user_info['is_admin'] || $user_info['id'] == $profile['id'] ? cdata_parse($profile['username']) : '',
				'name' => cdata_parse($profile['name']),
				'link' => $scripturl . '?action=profile;u=' . $profile['id'],
				'posts' => $profile['posts'],
				'post-group' => cdata_parse($profile['post_group']),
				'language' => cdata_parse($profile['language']),
				'last-login' => gmdate('D, d M Y H:i:s \G\M\T', $user_profile[$profile['id']]['last_login']),
				'registered' => gmdate('D, d M Y H:i:s \G\M\T', $user_profile[$profile['id']]['date_registered'])
			);

			// Everything below here might not be set, and thus maybe shouldn't be displayed.
			if ($profile['gender']['name'] != '')
				$data['gender'] = cdata_parse($profile['gender']['name']);

			if ($profile['avatar']['name'] != '')
				$data['avatar'] = $profile['avatar']['url'];

			// If they are online, show an empty tag... no reason to put anything inside it.
			if ($profile['online']['is_online'])
				$data['online'] = '';

			if ($profile['signature'] != '')
				$data['signature'] = cdata_parse($profile['signature']);

			if ($profile['blurb'] != '')
				$data['blurb'] = cdata_parse($profile['blurb']);

			if ($profile['location'] != '')
				$data['location'] = cdata_parse($profile['location']);

			if ($profile['title'] != '')
				$data['title'] = cdata_parse($profile['title']);

			if ($profile['website']['title'] != '')
				$data['website'] = array(
					'title' => cdata_parse($profile['website']['title']),
					'link' => $profile['website']['url']
				);

			if ($profile['group'] != '')
				$data['position'] = cdata_parse($profile['group']);

			if (!empty($modSettings['karmaMode']))
				$data['karma'] = array(
					'good' => $profile['karma']['good'],
					'bad' => $profile['karma']['bad']
				);

			if (in_array($profile['show_email'], array('yes', 'yes_permission_override')))
				$data['email'] = $profile['email'];

			if (!empty($profile['birth_date']) && substr($profile['birth_date'], 0, 4) != '0000')
			{
				list ($birth_year, $birth_month, $birth_day) = sscanf($profile['birth_date'], '%d-%d-%d');
				$datearray = getdate(forum_time());
				$data['age'] = $datearray['year'] - $birth_year - (($datearray['mon'] > $birth_month || ($datearray['mon'] == $birth_month && $datearray['mday'] >= $birth_day)) ? 0 : 1);
			}
		}

		// Save some memory.
		unset($profile, $memberContext[$uid]);

		return $data;
	}
}

/**
 * Called from dumpTags to convert data to xml
 * Finds urls for local site and santizes them
 *
 * @param string $val
 */
function fix_possible_url($val)
{
	global $modSettings, $context, $scripturl;

	if (substr($val, 0, strlen($scripturl)) != $scripturl)
		return $val;

	call_integration_hook('integrate_fix_url', array(&$val));

	if (empty($modSettings['queryless_urls']) || ($context['server']['is_cgi'] && ini_get('cgi.fix_pathinfo') == 0 && @get_cfg_var('cgi.fix_pathinfo') == 0) || (!$context['server']['is_apache'] && !$context['server']['is_lighttpd']))
		return $val;

	$val = preg_replace_callback('~^' . preg_quote($scripturl, '/') . '\?((?:board|topic)=[^#"]+)(#[^"]*)?$~', 'fix_possible_url_callback', $val);
	return $val;
}

/**
 * Callback function for the preg_replace_callback in fix_possible_url
 * Invoked when queryless_urls are enabled and the system supports them
 * Updated URLs to be of "queryless" style
 *
 * @param mixed[] $matches
 */
function fix_possible_url_callback($matches)
{
	global $scripturl;

	return $scripturl . '/' . strtr($matches[1], '&;=', '//,') . '.html' . (isset($matches[2]) ? $matches[2] : '');
}

/**
 * Ensures supplied data is properly encpsulated in cdata xml tags
 * Called from action_xmlprofile in News.controller.php
 *
 * @param string $data
 * @param string $ns
 */
function cdata_parse($data, $ns = '')
{
	global $cdata_override;

	// Are we not doing it?
	if (!empty($cdata_override))
		return $data;

	$cdata = '<![CDATA[';

	for ($pos = 0, $n = Util::strlen($data); $pos < $n; null)
	{
		$positions = array(
			Util::strpos($data, '&', $pos),
			Util::strpos($data, ']', $pos),
		);

		if ($ns != '')
			$positions[] = Util::strpos($data, '<', $pos);

		foreach ($positions as $k => $dummy)
		{
			if ($dummy === false)
				unset($positions[$k]);
		}

		$old = $pos;
		$pos = empty($positions) ? $n : min($positions);

		if ($pos - $old > 0)
			$cdata .= Util::substr($data, $old, $pos - $old);

		if ($pos >= $n)
			break;

		if (Util::substr($data, $pos, 1) == '<')
		{
			$pos2 = Util::strpos($data, '>', $pos);
			if ($pos2 === false)
				$pos2 = $n;

			if (Util::substr($data, $pos + 1, 1) == '/')
				$cdata .= ']]></' . $ns . ':' . Util::substr($data, $pos + 2, $pos2 - $pos - 1) . '<![CDATA[';
			else
				$cdata .= ']]><' . $ns . ':' . Util::substr($data, $pos + 1, $pos2 - $pos) . '<![CDATA[';

			$pos = $pos2 + 1;
		}
		elseif (Util::substr($data, $pos, 1) == ']')
		{
			$cdata .= ']]>&#093;<![CDATA[';
			$pos++;
		}
		elseif (Util::substr($data, $pos, 1) == '&')
		{
			$pos2 = Util::strpos($data, ';', $pos);

			if ($pos2 === false)
				$pos2 = $n;

			$ent = Util::substr($data, $pos + 1, $pos2 - $pos - 1);

			if (Util::substr($data, $pos + 1, 1) == '#')
				$cdata .= ']]>' . Util::substr($data, $pos, $pos2 - $pos + 1) . '<![CDATA[';
			elseif (in_array($ent, array('amp', 'lt', 'gt', 'quot')))
				$cdata .= ']]>' . Util::substr($data, $pos, $pos2 - $pos + 1) . '<![CDATA[';

			$pos = $pos2 + 1;
		}
	}

	$cdata .= ']]>';

	return strtr($cdata, array('<![CDATA[]]>' => ''));
}

/**
 * Formats data retrieved in other functions into xml format.
 * Additionally formats data based on the specific format passed.
 * This function is recursively called to handle sub arrays of data.

 * @param mixed[] $data the array to output as xml data
 * @param int $i the amount of indentation to use.
 * @param string|null $tag if specified, it will be used instead of the keys of data.
 * @param string $xml_format  one of rss, rss2, rdf, atom
 */
function dumpTags($data, $i, $tag = null, $xml_format = 'rss')
{
	// For every array in the data...
	foreach ($data as $key => $val)
	{
		// Skip it, it's been set to null.
		if ($val === null)
			continue;

		// If a tag was passed, use it instead of the key.
		$key = isset($tag) ? $tag : $key;

		// First let's indent!
		echo "\n", str_repeat("\t", $i);

		// Grr, I hate kludges... almost worth doing it properly, here, but not quite.
		if ($xml_format == 'atom' && $key == 'link')
		{
			echo '<link rel="alternate" type="text/html" href="', fix_possible_url($val), '" />';
			continue;
		}

		// If it's empty/0/nothing simply output an empty tag.
		if ($val == '')
			echo '<', $key, ' />';
		elseif ($xml_format == 'atom' && $key == 'category')
			echo '<', $key, ' term="', $val, '" />';
		else
		{
			// Beginning tag.
			if ($xml_format == 'rdf' && $key == 'item' && isset($val['link']))
			{
				echo '<', $key, ' rdf:about="', fix_possible_url($val['link']), '">';
				echo "\n", str_repeat("\t", $i + 1);
				echo '<dc:format>text/html</dc:format>';
			}
			elseif ($xml_format == 'atom' && $key == 'summary')
				echo '<', $key, ' type="html">';
			else
				echo '<', $key, '>';

			if (is_array($val))
			{
				// An array.  Dump it, and then indent the tag.
				dumpTags($val, $i + 1, null, $xml_format);
				echo "\n", str_repeat("\t", $i), '</', $key, '>';
			}
			// A string with returns in it.... show this as a multiline element.
			elseif (strpos($val, "\n") !== false || strpos($val, '<br />') !== false)
				echo "\n", fix_possible_url($val), "\n", str_repeat("\t", $i), '</', $key, '>';
			// A simple string.
			else
				echo fix_possible_url($val), '</', $key, '>';
		}
	}
}