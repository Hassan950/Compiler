import React from 'react';
import { Form, FormGroup, Col, Button, Row } from 'react-bootstrap';
import CodeEditor from './controls/CodeEditor';
import AlertDismissable from './controls/AlertDismissable';
import OutputBox from './controls/OutputBox';
import StatusImage from './controls/StatusImage';
import { CsvToHtmlTable } from 'react-csv-to-table';

class Editor extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      task: {
        lang: 'javascript',
        code: '',
      },
      response: {
        status: '0',
        message: '',
        symbolTable: '',
      },
    };

    this.handleRun = this.handleRun.bind(this);
    this.handleCodeChange = this.handleCodeChange.bind(this);
  }

  handleCodeChange(code) {
    const { task } = this.state;
    task.code = code;
    return this.setState({ task });
  }

  async handleRun(event) {
    event.preventDefault();
    const { stdout, stderr, symbolTable } = await window.electron.compile(
      JSON.stringify(this.state.task.code)
    );
    if (stderr.length) {
      this.setState({
        response: {
          status: '1',
          message: stderr,
          symbolTable: '',
        },
      });
    } else {
      this.setState({
        response: {
          status: '0',
          message: stdout,
          symbolTable,
        },
      });
    }
  }

  render() {
    return (
      <div className="container">
        <Form horizontal>
          <FormGroup controlId="code">
            <Row>
              <Col sm={6}>
                <CodeEditor
                  onChange={this.handleCodeChange}
                  code={this.state.task.code}
                />
              </Col>
              <Col sm={6}>
                <OutputBox
                  show={this.state.response.status === '0'}
                  message={this.state.response.message}
                />
              </Col>
            </Row>
          </FormGroup>
          <FormGroup>
            <Col sm={12}>
              <Button bsStyle="primary" type="button" onClick={this.handleRun}>
                Run
              </Button>
              <StatusImage
                hasError={this.state.response.status !== '0'}
                message={this.state.response.message}
              />
            </Col>
            <Col sm={10} />
          </FormGroup>
          <FormGroup>
            <Col sm={12}>
              <AlertDismissable
                show={this.state.response.status !== '0'}
                message={this.state.response.message}
              />
              {this.state.response.status === '0' && (
                <CsvToHtmlTable
                  data={this.state.response.symbolTable}
                  csvDelimiter=","
                  tableClassName="table table-striped table-hover"
                />
              )}
            </Col>
          </FormGroup>
        </Form>
      </div>
    );
  }
}

export default Editor;
