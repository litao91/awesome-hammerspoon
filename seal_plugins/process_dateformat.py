import calendar
from delorean import utcnow, parse, epoch
import json
import sys

def process(query_str):
    """ Entry point """
    value = parse_query_value(query_str)
    if value is not None:
        results = alfred_items_for_value(value)
        return results

def parse_query_value(query_str):
    """ Return value for the query string """
    try:
        query_str = str(query_str).strip('"\' ')
        if query_str == 'now':
            d = utcnow()
        else:
            # Parse datetime string or timestamp
            try:
                d = epoch(float(query_str))
            except ValueError:
                d = parse(str(query_str))
    except (TypeError, ValueError):
        d = None
    return d

def alfred_items_for_value(value):
    """
    Given a delorean datetime object, return a list of
    alfred items for each of the results
    """

    index = 0
    results = []

    # First item as timestamp
    item_value = calendar.timegm(value.datetime.utctimetuple())
    results.append(dict(
        text=str(item_value),
        subText=u'UTC Timestamp',
        arg= item_value,
            plugin='seal_dateformat',
    ))
    index += 1

    # Various formats
    formats = [
        # 1937-01-01 12:00:27
        ("%Y-%m-%d %H:%M:%S", ''),
        # 1937-01-01T12:00:27
        ("%Y-%m-%dT%H:%M:%S", ''),
        # 1996-12-19T16:39:57-0800
        ("%Y-%m-%dT%H:%M:%S%z", ''),
        # 19 May 2002 15:21:36
        ("%d %b %Y %H:%M:%S", ''),
        # Sun, 19 May 2002 15:21:36
        ("%a, %d %b %Y %H:%M:%S", ''),
    ]
    for format, description in formats:
        item_value = value.datetime.strftime(format)
        results.append(dict(
            text=str(item_value),
            subText=description,
            arg=item_value,
            plugin='seal_dateformat',
        ))
        index += 1

    return results

if __name__ == "__main__":
    try:
        query_str = sys.argv[1]
    except IndexError:
        query_str = None
    print(json.dumps(process(query_str)))
