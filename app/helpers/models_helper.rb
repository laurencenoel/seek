module ModelsHelper

  JWS_ERROR_TO_PANEL_NAMES={
    "reaction" => "Reactions",
    "kinetics" => "Rate equations",
    "initVal"=>"Initial values",
    "parameters"=>"Parameter values",
    "functions"=>"Functions",
    "assRules"=>"Assignment rules",
    "events"=>"Events",
    "annotated_reactions"=>"Annotations for processes",
    "annotated_species"=>"Annotations for species"
  }
  
  JWS_ERROR_TO_PREFIX={
    "reaction" => "reactions",
    "kinetics" => "equations",
    "initVal"=>"initial",
    "parameters"=>"parameters",
    "functions"=>"functions",
    "assRules"=>"assignments",
    "events"=>"events",
    "annotated_reactions"=>"annotated_reactions",
    "annotated_species"=>"annotated_species"
  }

  def model_environment_text model
    model.recommended_environment ? h(model.recommended_environment.title) : "<span class='none_text'>Unknown</span>" 
  end

  def model_jws_online_compatible? model
    !model.recommended_environment.nil? && model.recommended_environment.title.downcase=="jws online"
  end

  def execute_model_label
    icon_filename=icon_filename_for_key("execute")

    '<span class="icon">' + image_tag(icon_filename,:alt=>"Run",:title=>"Run") + ' Run model</span>';
  end

  def model_type_text model_type
    return "<span class='none_text'>Not specified</span>" if model_type.nil?
    h(model_type.title)
  end

  def model_format_text model_format
    return "<span class='none_text'>Not specified</span>" if model_format.nil?
    h(model_format.title)
  end
  
  def authorised_models
    models=Model.find(:all)
    Authorization.authorize_collection("show",models,current_user)
  end  
  
  def jws_supported? model
    builder = Seek::JWSModelBuilder.new
    builder.is_supported? model
  end

  def jws_annotator_hidden_fields params_hash
    required_params=["assignmentRules", "annotationsReactions", "annotationsSpecies", "modelname", "parameterset", "kinetics", "functions", "initVal", "reaction", "events", "steadystateanalysis", "plotGraphPanel", "plotKineticsPanel"]
    required_params.collect do |param|
      value = params_hash[param] || ""
      html=hidden_field_tag(param, "")
      #using javascript to decode the escaped strings (like \\n) as the URI.decode in ruby doesn't do this.
      html+="<script type='text/javascript'>$('#{param}').value=decodeURI('#{value}');</script>".html_safe
      html
    end
  end
  
  def jws_key_to_text key
    JWS_ERROR_TO_PANEL_NAMES[key]
  end
  
  def jws_key_to_prefix key
    JWS_ERROR_TO_PREFIX[key]  
  end

end
