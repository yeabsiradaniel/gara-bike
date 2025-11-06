import React, { useState, useEffect } from 'react';
import { Box, Typography, IconButton, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle, Button, TextField, Checkbox, FormControlLabel } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import dataService from '../services/dataService';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import AddIcon from '@mui/icons-material/Add';

const UsersPage = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [userToDelete, setUserToDelete] = useState(null);
  const [formDialogOpen, setFormDialogOpen] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);

  const fetchUsers = () => {
    setLoading(true);
    dataService.getAll('users')
      .then(response => {
        setUsers(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch users:", error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleOpenFormDialog = (user = null) => {
    setCurrentUser(user ? { ...user } : { username: '', email: '', password: '', phone_number: '', is_staff: false, is_active: false });
    setFormDialogOpen(true);
  };

  const handleCloseFormDialog = () => {
    setFormDialogOpen(false);
    setCurrentUser(null);
  };

  const handleSave = async () => {
    try {
      if (currentUser.id) {
        await dataService.update('users', currentUser.id, currentUser);
      } else {
        await dataService.create('users', currentUser);
      }
      fetchUsers();
      handleCloseFormDialog();
    } catch (error) {
      console.error("Failed to save user:", error);
    }
  };

  const handleDeleteClick = (id) => {
    setUserToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      await dataService.remove('users', userToDelete);
      fetchUsers();
      setDeleteDialogOpen(false);
      setUserToDelete(null);
    } catch (error) {
      console.error("Failed to delete user:", error);
    }
  };

  const columns = [
    { field: 'id', headerName: 'ID', width: 220 },
    { field: 'username', headerName: 'Username', width: 150 },
    { field: 'email', headerName: 'Email', width: 200 },
    { field: 'phone_number', headerName: 'Phone', width: 150 },
    { field: 'is_verified', headerName: 'Verified', type: 'boolean', width: 100 },
    { field: 'is_staff', headerName: 'Admin', type: 'boolean', width: 100 },
    { field: 'date_joined', headerName: 'Date Joined', type: 'dateTime', width: 200, valueGetter: (value) => new Date(value) },
    {
      field: 'actions',
      headerName: 'Actions',
      type: 'actions',
      width: 120,
      getActions: ({ id, row }) => [
        <IconButton color="primary" onClick={() => handleOpenFormDialog(row)}><EditIcon /></IconButton>,
        <IconButton color="error" onClick={() => handleDeleteClick(id)}><DeleteIcon /></IconButton>,
      ],
    },
  ];

  return (
    <Box sx={{ height: '85vh', width: '100%' }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
            <Typography variant="h4">Manage Users</Typography>
            <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenFormDialog()}>Create User</Button>
        </Box>
      <DataGrid
        rows={users}
        columns={columns}
        loading={loading}
        getRowId={(row) => row.id}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 10 },
          },
        }}
        pageSizeOptions={[5, 10, 20]}
        checkboxSelection
      />
      <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent><DialogContentText>Are you sure you want to delete this user?</DialogContentText></DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error">Delete</Button>
        </DialogActions>
      </Dialog>
      <Dialog open={formDialogOpen} onClose={handleCloseFormDialog}>
        <DialogTitle>{currentUser?.id ? 'Edit User' : 'Create User'}</DialogTitle>
        <DialogContent>
            {currentUser && (
                <Box component="form" sx={{ mt: 2 }}>
                    <TextField margin="dense" label="Username" fullWidth value={currentUser.username} onChange={(e) => setCurrentUser({ ...currentUser, username: e.target.value })} />
                    <TextField margin="dense" label="Email" fullWidth value={currentUser.email} onChange={(e) => setCurrentUser({ ...currentUser, email: e.target.value })} />
                    {!currentUser.id && <TextField margin="dense" label="Password" type="password" fullWidth onChange={(e) => setCurrentUser({ ...currentUser, password: e.target.value })} />}                    
                    <TextField margin="dense" label="Phone Number" fullWidth value={currentUser.phone_number} onChange={(e) => setCurrentUser({ ...currentUser, phone_number: e.target.value })} />
                    <FormControlLabel control={<Checkbox checked={currentUser.is_staff} onChange={(e) => setCurrentUser({ ...currentUser, is_staff: e.target.checked })} />} label="Admin" />
                    <FormControlLabel control={<Checkbox checked={currentUser.is_active} onChange={(e) => setCurrentUser({ ...currentUser, is_active: e.target.checked })} />} label="Active" />
                </Box>
            )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseFormDialog}>Cancel</Button>
          <Button onClick={handleSave}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default UsersPage;