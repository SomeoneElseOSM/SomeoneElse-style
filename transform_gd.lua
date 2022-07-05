--
-- If an object has name:gd, use that as name
--

function process(object)
    if ( object.tags['name:gd'] ~= nil ) then
        object.tags.name = object.tags['name:gd']
    end

    return object.tags
end

function ott.process_node(object)
    return process(object)
end

function ott.process_way(object)
    return process(object)
end

function ott.process_relation(object)
    return process(object)
end
