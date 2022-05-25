import React from 'react';
import PropTypes from 'prop-types';

// Import Brace and the AceEditor Component
import brace from 'brace';
import AceEditor from 'react-ace';
// Import a Mode (language)
import 'brace/mode/c_cpp';
// Import a Theme (okadia, github, xcode etc)
import 'brace/theme/github';

const editorStyle = {
  border: '1px solid lightgray',
};

class CodeEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};

    this.onChange = this.onChange.bind(this);
  }

  onChange(newValue) {
    this.props.onChange(newValue);
  }

  render() {
    return (
      <AceEditor
        style={editorStyle}
        readOnly={false}
        onChange={this.onChange}
        width="100%"
        mode="c_cpp"
        theme="monokai"
        name="aceCodeEditor"
        // onLoad={this.onLoad}
        fontSize={14}
        showPrintMargin
        showGutter
        highlightActiveLine
        value={this.props.code}
        editorProps={{
          $blockScrolling: true,
          enableBasicAutocompletion: true,
          enableLiveAutocompletion: true,
          enableSnippets: true,
        }}
        setOptions={{
          showLineNumbers: true,
          tabSize: 2,
          useWorker: false,
        }}
        annotations={[
          this.props.showAnnotations
            ? {
                row: +this.props.response.line - 1,
                type: 'error',
                text: this.props.response.message,
                column: 0,
              }
            : {},
        ]}
      />
    );
  }
}

CodeEditor.propTypes = {
  code: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  response: PropTypes.objectOf({
    line: PropTypes.number.isRequired,
    message: PropTypes.string.isRequired,
  }).isRequired,
  showAnnotations: PropTypes.bool.isRequired,
};

export default CodeEditor;
