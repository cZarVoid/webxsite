-- Required libraries
local http = require("socket.http")
local ltn12 = require("ltn12")
local htmlparser = require("htmlparser")

-- Function to fetch search results from Google
local function fetch_search_results(query)
    local search_url = "https://www.google.com/search?q=" .. query
    local response = {}
    
    http.request{
        url = search_url,
        sink = ltn12.sink.table(response)
    }

    return table.concat(response)
end

-- Function to parse search results and extract titles and links
local function parse_search_results(html)
    local tree = htmlparser.parse(html)
    local results = {}

    -- Assuming results are in <h3> tags with class "LC20lb"
    for _, node in ipairs(tree:select("h3.LC20lb")) do
        local title = node:getcontent()
        local link_node = node:parent()
        if link_node.tag == "a" then
            local link = link_node:getattribute("href")
            table.insert(results, {title = title, link = link})
        end
    end

    return results
end

-- Function to update HTML content with search results
local function update_html_with_results(results)
    local results_html = ""
    for _, result in ipairs(results) do
        results_html = results_html .. string.format(
            '<li><a href="%s">%s</a></li>',
            result.link,
            result.title
        )
    end

    local results_div = get("results")
    results_div.set_content('<ul>' .. results_html .. '</ul>')
end

-- Main coroutine to fetch and display search results
coroutine.wrap(function()
    local query = "Lua programming"
    local html = fetch_search_results(query)
    local results = parse_search_results(html)
    update_html_with_results(results)
end)()