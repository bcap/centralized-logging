class centralizedlogging::elasticsearch {

  $clustername = "centralizedlogging"

  class { ::elasticsearch :
    elasticsearch_config_template => "centralizedlogging/$hostname/elasticsearch.yml",
    logging_config_template => "centralizedlogging/$pool/logging.yml",
  }
}

class centralizedlogging::logstash {

  class { ::logstash : }

}