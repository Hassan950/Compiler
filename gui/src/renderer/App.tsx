import { MemoryRouter as Router, Routes, Route } from 'react-router-dom';
import icon from '../../assets/icon.svg';
import Header from './Header';
import Footer from './Footer';
import Home from './Home';
import Editor from './Editor';
import './App.css';
import 'bootstrap/dist/css/bootstrap.min.css';

export default function App() {
  return (
    <>
      <Router>
        <Header />
        <Routes>
          <Route path="/" element={<Editor />} />
        </Routes>
      </Router>
    </>
  );
}
