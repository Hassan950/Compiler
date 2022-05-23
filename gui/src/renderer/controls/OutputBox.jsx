import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';

class OutputBox extends React.Component {
  constructor(props, context) {
    super(props, context);
    this.state = {};
  }

  render() {
    if (this.props.show) {
      return (
        <Form.Control
          name="code"
          as="textarea"
          rows="8"
          readOnly
          style={{
            height: '100%',
            resize: 'none',
          }}
          value={this.props.message}
        />
      );
    }

    return (
      <Form.Control
        name="code"
        as="textarea"
        rows="8"
        readOnly
        style={{
          height: '100%',
          resize: 'none',
        }}
        value=""
      />
    );
  }
}

OutputBox.propTypes = {
  show: PropTypes.bool.isRequired,
  message: PropTypes.string.isRequired,
};

export default OutputBox;
