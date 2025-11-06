import React, { useState, useEffect } from 'react';
import { Box, Typography, IconButton, Dialog, DialogActions, DialogContent, DialogTitle, Button, TextField, Select, MenuItem, FormControl, InputLabel } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import dataService from '../services/dataService';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';

const SupportTicketsPage = () => {
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [ticketToDelete, setTicketToDelete] = useState(null);
  const [formDialogOpen, setFormDialogOpen] = useState(false);
  const [currentTicket, setCurrentTicket] = useState(null);

  const fetchSupportTickets = () => {
    setLoading(true);
    dataService.getAll('support-tickets')
      .then(response => {
        setTickets(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch support tickets:", error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchSupportTickets();
  }, []);

  const handleOpenFormDialog = (ticket) => {
    setCurrentTicket({ ...ticket });
    setFormDialogOpen(true);
  };

  const handleCloseFormDialog = () => {
    setFormDialogOpen(false);
    setCurrentTicket(null);
  };

  const handleSave = async () => {
    try {
      await dataService.update('support-tickets', currentTicket.id, { status: currentTicket.status });
      fetchSupportTickets();
      handleCloseFormDialog();
    } catch (error) {
      console.error("Failed to save support ticket:", error);
    }
  };

  const handleDeleteClick = (id) => {
    setTicketToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      await dataService.remove('support-tickets', ticketToDelete);
      fetchSupportTickets();
      setDeleteDialogOpen(false);
      setTicketToDelete(null);
    } catch (error) {
      console.error("Failed to delete support ticket:", error);
    }
  };

  const columns = [
    { field: 'id', headerName: 'Ticket ID', width: 220 },
    { field: 'user', headerName: 'User', width: 220, valueGetter: (value) => value.email },
    { field: 'subject', headerName: 'Subject', width: 250 },
    { field: 'message', headerName: 'Message', width: 350 },
    { field: 'status', headerName: 'Status', width: 120 },
    { field: 'created_at', headerName: 'Created At', type: 'dateTime', width: 180, valueGetter: (value) => new Date(value) },
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
      <Typography variant="h4" sx={{ mb: 4 }}>Manage Support Tickets</Typography>
      <DataGrid
        rows={tickets}
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
      <Dialog open={deleteDialogOpen} onClose={handleCloseFormDialog}>
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent><p>Are you sure you want to delete this support ticket?</p></DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error">Delete</Button>
        </DialogActions>
      </Dialog>
      <Dialog open={formDialogOpen} onClose={handleCloseFormDialog}>
        <DialogTitle>Edit Support Ticket</DialogTitle>
        <DialogContent>
            {currentTicket && (
                <Box component="form" sx={{ mt: 2, minWidth: 300 }}>
                    <FormControl fullWidth margin="dense">
                        <InputLabel>Status</InputLabel>
                        <Select
                            value={currentTicket.status}
                            label="Status"
                            onChange={(e) => setCurrentTicket({ ...currentTicket, status: e.target.value })}
                        >
                            <MenuItem value="OPEN">OPEN</MenuItem>
                            <MenuItem value="IN_PROGRESS">IN_PROGRESS</MenuItem>
                            <MenuItem value="CLOSED">CLOSED</MenuItem>
                        </Select>
                    </FormControl>
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

export default SupportTicketsPage;