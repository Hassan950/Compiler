import React from 'react';
import { Button, ButtonToolbar } from 'react-bootstrap';
import { useNavigate } from 'react-router-dom';

const Header = () => {
  const navigate = useNavigate();
  return (
    <div>
      <div className="container">
        <h2>Compilers Project</h2>
        <ButtonToolbar>
          <Button bsStyle="info" onClick={() => navigate('/')}>
            Home
          </Button>
        </ButtonToolbar>
      </div>
      <hr />
    </div>
  );
};

export default Header;
